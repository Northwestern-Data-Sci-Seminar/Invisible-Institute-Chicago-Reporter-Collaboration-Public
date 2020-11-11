from sklearn.model_selection import train_test_split
import sklearn.metrics as metrics
from sklearn.model_selection import cross_val_score
from sklearn.ensemble import RandomForestClassifier
from sklearn.neighbors import KNeighborsClassifier
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from sklearn import preprocessing
from sklearn.tree import export_graphviz
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier



# cp4 question 1: predict discipline
file_path = 'cp4_data_all.csv'
df = pd.read_csv (file_path)
df = pd.DataFrame(df,columns=['gender','race','rank','complaint_percentile','allegation_count','category','disciplined'])
df = df.dropna()
y = df[['disciplined']]

# visualize class imbalance between number of disciplined allegations
print(" *** Original class imbalance: ***")
print(y.value_counts())
plt.title("Original Class Imbalance")
plt.bar(*zip(*y['disciplined'].value_counts().items()))
plt.xlabel('False vs True (Disciplined)')
plt.ylabel('Frequency')
plt.show()

# resample to fix imbalance
class_0 = df[df['disciplined'] == False]
class_1 = df[df['disciplined'] == True]
class_count_0, class_count_1 = df['disciplined'].value_counts()
class_1_over = class_1.sample(class_count_0, replace=True)
data_over = pd.concat([class_1_over, class_0], axis=0)

print("*** New fixed class imbalance: ***\n", data_over['disciplined'].value_counts())
plt.title("New Fixed Class Imbalance")
plt.bar(*zip(*data_over['disciplined'].value_counts().items()))
plt.xlabel('False vs True (Disciplined)')
plt.ylabel('Frequency')
plt.show()

y = data_over[['disciplined']]
X = data_over[['race', 'rank', 'complaint_percentile', 'allegation_count', 'category']]

# preprocess data to encode categorical data as numeric
le = preprocessing.LabelEncoder()
for column_name in X.columns:
    if X[column_name].dtype == object:
        X[column_name] = le.fit_transform(X[column_name])


X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.20)
clf = RandomForestClassifier(n_estimators=10)
clf.fit(X_train, y_train)
y_pred = clf.predict(X_test)
scores = cross_val_score(clf, X, y, cv=5, scoring='accuracy')  # try using 'accuracy', 'precision', 'recall', and 'f1_macro' for the scoring parameter
print("CV scores = ", scores)
print(metrics.classification_report(y_test, y_pred, digits=3))


# # cp4 question 2: predict settlement amount
# file_path = 'cp4_question_2_predict_settlement_amount.csv'
# df = pd.read_csv (file_path)
# df = pd.DataFrame(df,columns=['gender', 'race', 'rank', 'interactions', 'outcomes', 'misconducts', 'violences', 'primary_cause', 'total_settlement'])
# df = df.dropna()
# df = df[df['total_settlement'] >= 10]
# y = df[['total_settlement']].astype(int)
# y = y.transform(lambda x: np.floor(np.log10(x))) # predict the magnitude (e.g. 10 is 1, 100 is 2, 1000 is 3...)
# X = df[['interactions', 'outcomes', 'misconducts', 'gender', 'race']]
#
#
# # ************* Average settlemt cost by gender *************
# df2 = df[['gender', 'total_settlement']]
# df2 = df2[df2['gender'] == 'F']
# df3 = df[['gender', 'total_settlement']]
# df3 = df3[df3['gender'] == 'M']
# plt.bar(['Female','Male'], [np.int(df2.mean()), np.int(df3.mean())], color='red')
# plt.title("Average settlement cost by gender")
# plt.show()
#
# # ************* Average settlemt cost by race *************
#
# df4 = df[['race', 'total_settlement']]
# df4 = df4[df4['race'] == 'White']
#
# df5 = df[['race', 'total_settlement']]
# df5 = df5[df5['race'] == 'Hispanic']
#
# df6 = df[['race', 'total_settlement']]
# df6 = df6[df6['race'] == 'Black']
#
# df7 = df[['race', 'total_settlement']]
# df7 = df7[df7['race'] == 'Asian/Pacific']
#
# df8 = df[['race', 'total_settlement']]
# df8 = df8[df8['race'] == 'Native American/Alaskan Native']
#
# plt.bar(['White','Hispanic', 'Black', 'Asian/Pacific', 'Native American/Alaskan Native'], [np.int(df4.mean()), np.int(df5.mean()), np.int(df6.mean()), np.int(df7.mean()), np.int(df8.mean())], color='red')
# plt.title("Average settlement cost by race")
# plt.show()
#
#
#
# #preprocess data to encode categorical data as numeric
# le = preprocessing.LabelEncoder()
# for column_name in X.columns:
#     if X[column_name].dtype == object:
#         X[column_name] = le.fit_transform(X[column_name])
#
# X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.30, random_state = 5)
# clf = KNeighborsClassifier(n_neighbors=3, weights='distance')
# clf.fit(X_train, y_train)
# y_pred = clf.predict(X_test)
# scores = cross_val_score(clf, X, y, cv=4, scoring='accuracy') #try using 'accuracy', 'precision', 'recall', and 'f1_macro' for the scoring parameter
# print("CV scores = ",scores)
# print(metrics.classification_report(y_test, y_pred, digits=3))
