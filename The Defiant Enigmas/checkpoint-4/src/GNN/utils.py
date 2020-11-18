import numpy as np
import psycopg2 as psql
import torch
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


def column_normalize(tensor):
    # if values are the same, returned vector will be all 1
    if not torch.allclose(tensor.min(), tensor.max()):
        tensor = tensor - tensor.min(dim=0)[0].unsqueeze(0)
    tensor = tensor / (tensor.max(dim=0)[0].unsqueeze(0) + 1e-6)
    return tensor


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
        "user": "postgres",
        "password": "12345678",
        "host": "127.0.0.1",
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

    # pad 0 to other officers
    length = len(officer_info[o_idx])
    for idx, oi in enumerate(officer_info):
        if len(oi) != length:
            officer_info[idx] = oi + (0.0,) * (length - len(oi))

    cur.execute("""
            select doa1.officer_id as officer1, doa2.officer_id as officer2, count(doa1.id)
            from data_officerallegation as doa1
                   join data_officerallegation as doa2
                     on doa1.allegation_id = doa2.allegation_id and doa1.officer_id != doa2.officer_id
            where extract(year from doa1.start_date) {} {} 
                and doa1.officer_id in (select id from tmp_officer_info)
                and doa2.officer_id in (select id from tmp_officer_info)
            group by doa1.officer_id, doa2.officer_id
        """.format('<=' if is_until_year else '=', year, year))
    officer_relation = cur.fetchall()
    officer_relation = [
        (officer_index[ori[0]],
         officer_index[ori[1]],
         ori[2])
        for ori in officer_relation
    ]

    # create tensor for features and adjacency matrix
    features = torch.tensor(officer_info, dtype=torch.float32)
    adjacency = torch.tensor(officer_relation, dtype=torch.long)[:, 0:2]
    adjacency_weight = torch.tensor(officer_relation, dtype=torch.float32)[:, 2]\
        .view(adjacency.shape[0], 1)
    target = torch.tensor(target, dtype=torch.float32)\
        .view(features.shape[0], 1)

    features = column_normalize(features)
    adjacency_weight = column_normalize(adjacency_weight)

    return officer_id, features, adjacency, adjacency_weight, target


def shift_adjacency_and_concat(features_list,
                               adjacency_list,
                               adjacency_weight_list,
                               target_list):
    adj_prefix = [0] + [f.shape[0] for f in features_list]
    adj_prefix = [adj_prefix[i] + (adj_prefix[i - 1] if i > 0 else 0)
                  for i in range(len(adj_prefix))][:-1]
    for adj_p, adj in zip(adj_prefix, adjacency_list):
        adj += adj_p

    return (
        torch.cat(features_list, dim=0),
        torch.cat(adjacency_list, dim=0),
        torch.cat(adjacency_weight_list, dim=0),
        torch.cat(target_list, dim=0)
    )


def get_split(officer_num, adjacency, train_validate_test_ratio):
    # Compute range.
    range = np.arange(officer_num)
    np.random.shuffle(range)
    train_size, val_size = (
        int(np.floor(train_validate_test_ratio[0] * len(range)
                     / sum(train_validate_test_ratio))),
        int(np.floor(train_validate_test_ratio[1] * len(range)
                     / sum(train_validate_test_ratio)))
    )
    train_nodes = set(range[:train_size])
    val_nodes = set(range[train_size: train_size + val_size])
    test_nodes = set(range[train_size + val_size:])

    # Remove nodes.
    # Will completely remove nodes in the test and validation set
    # which are adjacent to nodes in the train set.
    train_adj_set = train_nodes.union(
        set(int(adj[1]) for adj in adjacency if adj[0] in train_nodes)
    )
    val_nodes = val_nodes - train_adj_set
    test_nodes = test_nodes - train_adj_set

    return train_nodes, val_nodes, test_nodes


def get_data(train_validate_test_ratio=(4, 1, 1),
             min_year=2000,
             max_year=2013,
             is_until_year=True,
             **credential):
    print("Generating cpdb dataset...")
    conn = get_conn(**credential)
    oid_list, f_list, adj_list, adj_w_list, t_list = [], [], [], [], []
    for year in range(min_year, max_year):
        oid, f, adj, adj_w, t = get_officer_info(conn, year, is_until_year)
        oid_list += oid
        f_list.append(f)
        adj_list.append(adj)
        adj_w_list.append(adj_w)
        t_list.append(t)
        print("Adding year {}...".format(year))
    conn.close()
    f, adj, adj_w, t = shift_adjacency_and_concat(f_list, adj_list,
                                                  adj_w_list, t_list)

    train_n, val_n, test_n = get_split(f.shape[0], adj,
                                       train_validate_test_ratio)
    train_adj_idx = [idx for idx, a in enumerate(adj) if int(a[0]) in train_n]
    val_adj_idx = [idx for idx, a in enumerate(adj) if int(a[0]) in val_n]
    test_adj_idx = [idx for idx, a in enumerate(adj) if int(a[0]) in test_n]

    print("Dataset processing finished, {} nodes, {} edges in total"
          .format(f.shape[0], adj.shape[0]))
    return (
        oid_list, f,
        [adj[train_adj_idx], adj_w[train_adj_idx], t[list(train_n)], list(train_n)],
        [adj[val_adj_idx], adj_w[val_adj_idx], t[list(val_n)], list(val_n)],
        [adj[test_adj_idx], adj_w[test_adj_idx], t[list(test_n)], list(test_n)]
    )

