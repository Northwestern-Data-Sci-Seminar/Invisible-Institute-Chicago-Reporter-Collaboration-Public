import torch
from sklearn import tree, metrics
import numpy as np
import pandas as pd
import utils
import tables
from matplotlib import pyplot as plt


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
    officer_info = [utils.get_onehot_encoding(tables.gender_table, roi[1])
                    + utils.get_onehot_encoding(tables.race_table, roi[2])
                    + (utils.get_normalized_year(roi[3], roi[5] or year),
                       utils.get_normalized_year(roi[4], year))
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
                    utils.get_percent(lambda x: x == "SU", rai[2]),
                    # total sustained rate
                ) + utils.get_percent_histogram(tables.final_outcome_table, rai[3])
                + utils.get_percent_histogram(tables.allegation_table, rai[4])
                + (utils.get_percent(lambda x: x, rai[5]),  # disciplined rate
                   utils.get_percent(lambda x: x, rai[6]))  # officer complainant rate
                + utils.get_percent_histogram(tables.race_table, rai[7])  # victim race
                + (utils.get_normalized_year(0, rai[8]),))  # victim age

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
    adjacency_weight = torch.tensor(officer_relation, dtype=torch.float32)[:, 2] \
        .view(adjacency.shape[0], 1)
    target = torch.tensor(target, dtype=torch.float32) \
        .view(features.shape[0], 1)

    features = utils.column_normalize(features)
    adjacency_weight = utils.column_normalize(adjacency_weight)

    return officer_id, features, adjacency, adjacency_weight, target


def split_data(data):
    x = data.values[:, 1:5]
    y = data.values[:, 0]
    X_train, X_test, y_train, y_test = torch.train_test_split(
        x, y, test_size=0.3, random_state=100)
    return x, y, X_train, X_test, y_train, y_test


def train_using_gini(X_train, y_train):
    clf_gini = tree.DecisionTreeClassifier(criterion="gini",
                                           random_state=100,
                                           max_depth=3,
                                           min_samples_leaf=5)
    # Performing training
    clf_gini.fit(X_train, y_train)
    return clf_gini


def train_using_entropy(X_train, y_train):
    # Decision tree with entropy
    clf_entropy = tree.DecisionTreeClassifier(criterion="entropy",
                                              random_state=100,
                                              max_depth=3,
                                              min_samples_leaf=5)
    # Performing training
    clf_entropy.fit(X_train, y_train)
    return clf_entropy


def train_using_regression(X_train, y_train):
    # Decision tree with entropy
    clf_regression = tree.DecisionTreeRegressor(random_state=100, max_depth=3, min_samples_leaf=5)
    # Performing training
    clf_regression.fit(X_train, y_train)
    return clf_regression


def prediction(X, y, clf_object):
    # Predicton on test with giniIndex
    y_pred = clf_object.predict(X)
    #print("Predicted values:")
    #print(y_pred)
    print("\nMean Squared Error: {}".format(metrics.mean_squared_error(y, y_pred)))
    return y_pred


def main():
    # Building Phase
    oid, f, t, train_n, val_n, test_n = utils.get_data()
    X_train = f[train_n]
    X_test = f[test_n]
    X_val = f[val_n]
    y_train = t[train_n].flatten()
    y_test = t[test_n].flatten()
    y_val = t[val_n].flatten()
    clf_gini = train_using_gini(X_train, y_train)
    clf_entropy = train_using_entropy(X_train, y_train)
    clf_regression = train_using_regression(X_train, y_train)
    # Operational Phase
    print("Results Using Gini Index:")
    # Prediction using gini
    print("\t-- Training --")
    y_pred_gini = prediction(X_train, y_train, clf_gini)
    print("\t-- Validation --")
    y_pred_gini = prediction(X_val, y_val, clf_gini)
    print("\t-- Testing --")
    y_pred_gini = prediction(X_test, y_test, clf_gini)
    print("\nResults Using Entropy:")
    # Prediction using entropy
    print("\t-- Training --")
    y_pred_entropy = prediction(X_train, y_train, clf_entropy)
    print("\t-- Validation --")
    y_pred_entropy = prediction(X_val, y_val, clf_entropy)
    print("\t-- Testing --")
    y_pred_entropy = prediction(X_test, y_test, clf_entropy)
    # Prediction using regression
    print("\t-- Training --")
    y_pred_regression = prediction(X_train, y_train, clf_regression)
    print("\t-- Validation --")
    y_pred_regression = prediction(X_val, y_val, clf_regression)
    print("\t-- Testing --")
    y_pred_regression = prediction(X_test, y_test, clf_regression)


    feature_names = ["Gender: Male",
                     "Gender: Female",
                     "Officer Race: White",
                     "Officer Race: Unknown",
                     "Officer Race: Native American/Alaskan Native",
                     "Officer Race: Black",
                     "Officer Race: Asian/Pacific",
                     "Officer Race: Hispanic",
                     "Normalized Career Length",
                     "Normalized Birth Year",
                     "Number of prior allegations",
                     "Sustained allegation rate",
                     "Final Outcome",
                     "Final Outcome",
                     "Final Outcome",
                     "Final Outcome",
                     "Final Outcome",
                     "Final Outcome",
                     "Final Outcome",
                     "Allegation Type",
                     "Allegation Type",
                     "Allegation Type",
                     "Allegation Type",
                     "Allegation Type",
                     "Allegation Type",
                     "Allegation Type",
                     "Allegation Type",
                     "Allegation Type",
                     "Allegation Type",
                     "Allegation Type",
                     "Allegation Type",
                     "Allegation Type",
                     "Allegation Type",
                     "Disciplined Rate",
                     "Officer Complaint Rate",
                     "Complainant Race: White",
                     "Complainant Race: Unknown",
                     "Complainant Race: Native American/Alaskan Native",
                     "Complainant Race: Black",
                     "Complainant Race: Asian/Pacific",
                     "Complainant Race: Hispanic",
                     "Complainant Age"]

    fig = plt.figure(figsize=(28,8))
    tree.plot_tree(clf_regression, feature_names=feature_names, filled=True, fontsize=6)
    plt.show()


# Calling main function
if __name__ == "__main__":
    main()
