import numpy as np
import torch
import psycopg2 as psql
from tables import *
g_lut = {}


def lookup(table, key, lookfor_idx=True):
    if not isinstance(table[-1], dict):
        lut = {}
        for i, k in enumerate(table):
            if isinstance(k, tuple):
                for val in k:
                    lut[val] = i
            else:
                lut[k] = i
        g_lut[id(table)] = lut
    if lookfor_idx:
        return g_lut[id(table)].get(key, None)
    else:
        return table[key]


def is_sql_json_agg_empty(column):
    return len(column) == 1 and column[0] is None


def column_normalize(array):
    # if values are the same, returned vector will be all 1
    if not np.allclose(array.min(), array.max()):
        array = array - array.min(axis=0)[0].unsqueeze(0)
    array = array / (array.max(axis=0)[0].unsqueeze(0) + 1e-6)
    return array


def get_normalized_year(start_year, end_year):
    if start_year is None or end_year is None:
        return 0
    else:
        return max((end_year - start_year) / 100, 0)


def get_onehot_encoding(table, column):
    idx = lookup(table, column)
    onehot = [0] * len(table)
    if idx is not None:
        onehot[idx] = 1
    return tuple(onehot)


def get_percent_histogram(table, column):
    histogram = [0] * len(table)
    if not is_sql_json_agg_empty(column):
        for val in column:
            idx = lookup(table, val)
            if idx is not None:
                histogram[idx] += 1
    return tuple(map(lambda x: x / len(column), histogram))


def get_percent(filter_func, column):
    count = 0
    if not is_sql_json_agg_empty(column):
        count = sum(1 if filter_func(ele) else 0 for ele in column)
    return count / len(column)


def get_conn(**credential):
    default_cred = {
        "database": "cpdb",
        "user": "cpdb-student",
        "password": "dataSci4lyf",
        "host": "cpdb.cgod7egsd6vr.us-east-2.rds.amazonaws.com",
        "port": "5432"
    }
    default_cred.update(credential)
    conn = psql.connect(**default_cred)
    return conn


def get_officer_info(conn, year, is_until_year=True):
    cur = conn.cursor()
    cur.execute("drop table if exists tmp_officer_info")
    cur.execute("""
        create temp table tmp_officer_info as
        select dao.id,
               dao.gender,
               dao.race,
               extract(year from dao.appointed_date)   as appointed_year,
               dao.birth_year,
               extract(year from dao.resignation_date) as resign_year,
               count(doa.id)
        from data_officer as dao
               left join data_officerallegation as doa on dao.id = doa.officer_id 
               and extract(year from doa.start_date) = {}
        where extract(year from dao.appointed_date) <= {}
        group by dao.id;
    """.format(year + 1, year))
    cur.execute("select * from tmp_officer_info")
    raw_officer_info = cur.fetchall()
    officer_info = [get_onehot_encoding(gender_table, roi[1])
                    + get_onehot_encoding(race_table, roi[2])
                    + (get_normalized_year(roi[3], roi[5] or year),
                       get_normalized_year(roi[4], year))
                    for roi in raw_officer_info]
    # 2 + 6 + 1 + 1
    officer_id = [roi[0] for roi in raw_officer_info]
    target = [roi[6] for roi in raw_officer_info]
    officer_index = {roi[0]: idx for idx, roi in enumerate(raw_officer_info)}

    cur.execute("""
        select dao.id,
               json_agg(extract(year from start_date))                              as start_year,
               json_agg(final_finding)                                              as final_finding,
               json_agg(final_outcome)                                              as final_outcome,
               json_agg(coalesce(category, 'Unknown'))                              as allegation_category,
               json_agg(disciplined)                                                as disciplined,
               json_agg(is_officer_complaint)                                       as is_officer_complaint,
               json_agg(dv.gender)                                                  as victim_gender,
               coalesce(avg(extract(year from start_date) - dv.birth_year), 0)      as victim_age
        from data_officer as dao
               left join data_officerallegation as doa on dao.id = doa.officer_id
               left join data_allegation as da on doa.allegation_id = da.crid
               left join data_allegationcategory as dac on doa.allegation_category_id = dac.id
               left join data_victim as dv on doa.allegation_id = dv.allegation_id
        where extract(year from start_date) {} {} and extract(year from dao.appointed_date) <= {}
        group by dao.id
    """.format('<=' if is_until_year else '=', year, year))
    raw_total_allegation_info = cur.fetchall()
    o_idx = None
    for rai in raw_total_allegation_info:
        o_idx = officer_index[rai[0]]
        officer_info[o_idx] += (
                (
                    len(rai[1]),  # number of total allegations till year
                    get_percent(lambda x: x == "SU", rai[2]),
                    # total sustained rate
                ) + get_percent_histogram(final_outcome_table, rai[3])
                + get_percent_histogram(allegation_table, rai[4])
                + (get_percent(lambda x: x, rai[5]),  # disciplined rate
                   get_percent(lambda x: x, rai[6]))  # officer complainant rate
                + get_percent_histogram(race_table, rai[7])  # victim race
                + (get_normalized_year(0, rai[8]),))  # victim age
    # + 1 + 1 + 7 + 14 = 42
    # pad 0 to other officers
    length = len(officer_info[o_idx])
    for idx, oi in enumerate(officer_info):
        if len(oi) != length:
            officer_info[idx] = oi + (0.0,) * (length - len(oi))

    # create tensor for features and adjacency matrix
    features = torch.tensor(officer_info, dtype=torch.float32)
    target = torch.tensor(target, dtype=torch.float32).reshape(features.shape[0], 1)
    features = column_normalize(features)

    return officer_id, features, target


def get_split(officer_num, train_validate_test_ratio):
    # Compute range.
    range = np.arange(officer_num)
    np.random.shuffle(range)
    train_size, val_size = (
        int(np.floor(train_validate_test_ratio[0] * len(range)
                     / sum(train_validate_test_ratio))),
        int(np.floor(train_validate_test_ratio[1] * len(range)
                     / sum(train_validate_test_ratio)))
    )
    train_nodes = range[:train_size]
    val_nodes = range[train_size: train_size + val_size]
    test_nodes = range[train_size + val_size:]

    return train_nodes, val_nodes, test_nodes


def get_data(train_validate_test_ratio=(4, 1, 1),
             min_year=2000,
             max_year=2013,
             is_until_year=True,
             **credential):
    print("Generating cpdb dataset...")
    conn = get_conn(**credential)
    oid_list, f_list, t_list = [], [], []
    for year in range(min_year, max_year):
        oid, f, t = get_officer_info(conn, year, is_until_year)
        oid_list += oid
        f_list.append(f)
        t_list.append(t)
        print("Adding year {}...".format(year))
    conn.close()
    f = np.concatenate(f_list, axis=0)
    t = np.concatenate(t_list, axis=0)

    train_n, val_n, test_n = get_split(f.shape[0], train_validate_test_ratio)

    print("Dataset processing finished, {} officers in total"
          .format(f.shape[0]))

    return oid_list, f, t, train_n, val_n, test_n
