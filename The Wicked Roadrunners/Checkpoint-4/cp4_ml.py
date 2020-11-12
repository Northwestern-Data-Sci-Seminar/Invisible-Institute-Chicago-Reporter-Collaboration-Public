from sklearn.model_selection import train_test_split
import sklearn.metrics as metrics
from sklearn.model_selection import cross_val_score
from sklearn.ensemble import RandomForestClassifier
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from sklearn import preprocessing

# helper function to plot disciplined counts based on specific input features as bar chart
def bar_graph_helper(df_list):
    true_list = []
    false_list = []
    for df in df_list:
        f, t = df.value_counts().tolist()
        false_list.append(f)
        true_list.append(t)
    return false_list, true_list

# https://matplotlib.org/3.1.1/gallery/lines_bars_and_markers/barchart.html#sphx-glr-gallery-lines-bars-and-markers-barchart-py
def autolabel(rects):
    """Attach a text label above each bar in *rects*, displaying its height."""
    for rect in rects:
        height = rect.get_height()
        ax.annotate('{}'.format(height),
                    xy=(rect.get_x() + rect.get_width() / 2, height),
                    xytext=(0, 3),  # 3 points vertical offset
                    textcoords="offset points",
                    ha='center', va='bottom')


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

# plot fixed class imbalance
print("*** New fixed class imbalance: ***\n", data_over['disciplined'].value_counts())
plt.title("New Fixed Class Imbalance")
plt.bar(*zip(*data_over['disciplined'].value_counts().items()))
plt.xlabel('False vs True (Disciplined)')
plt.ylabel('Frequency')
plt.show()

# split data into input/output vectors after fixing class imbalance
y = data_over[['disciplined']]
X = data_over[['race', 'rank', 'complaint_percentile', 'allegation_count', 'category']]


# see relationship between race and disciplined
df4 = df[['race', 'disciplined']]
df4 = df4[df4['race'] == 'White']
df5 = df[['race', 'disciplined']]
df5 = df5[df5['race'] == 'Hispanic']
df6 = df[['race', 'disciplined']]
df6 = df6[df6['race'] == 'Black']
df7 = df[['race', 'disciplined']]
df7 = df7[df7['race'] == 'Asian/Pacific']
df8 = df[['race', 'disciplined']]
df8 = df8[df8['race'] == 'Native American/Alaskan Native']
false_list, true_list  = bar_graph_helper([df4, df5, df6, df7, df8])
races = ['White', 'Hispanic', 'Black', 'Asian/Pacific', 'Native American/Alaskan Native']
w = 0.3
fig, ax = plt.subplots()
x = np.arange(len(races))  # the label locations
rects1 = ax.bar(x - w/2, true_list, w, label='disciplined', color='blue')
rects2 = ax.bar(x + w/2, false_list, w, label='not disciplined', color='red')
ax.set_title("Discipline by race")
ax.set_xticks(x)
ax.set_xticklabels(races)
ax.legend()
autolabel(rects1)
autolabel(rects2)
fig.tight_layout()
plt.show()

# look at breakdown of other input features
print("\n\n*** RANK ***")
print(df.loc[:,'rank'].value_counts())
print("\n\n*** MISCONDUCT CATEGORY ***")
print(df.loc[:,'category'].value_counts())
print("\n\n*** COMPLAINT PERCENTILE ***")
print(df.loc[:,'complaint_percentile'].describe())
print("\n\n*** ALLEGATION COUNT ***")
print(df.loc[:,'allegation_count'].describe())



# preprocess data to encode categorical data as numeric
le = preprocessing.LabelEncoder()
for column_name in X.columns:
    if X[column_name].dtype == object:
        X[column_name] = le.fit_transform(X[column_name])




X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.20)
clf = RandomForestClassifier(n_estimators=15)
clf.fit(X_train, y_train)
y_pred = clf.predict(X_test)
scores = cross_val_score(clf, X, y, cv=5, scoring='accuracy')  # try using 'accuracy', 'precision', 'recall', and 'f1_macro' for the scoring parameter
print("CV scores = ", scores)
print(metrics.classification_report(y_test, y_pred, digits=3))


# cp4 question 2: predict settlement amount

file_path = 'cp4_question_2_predict_settlement_amount.csv'
df = pd.read_csv (file_path)
df = pd.DataFrame(df,columns=['gender', 'race', 'rank', 'interactions', 'outcomes', 'misconducts', 'violences', 'primary_cause', 'total_settlement'])
df = df.dropna()
df = df[df['total_settlement'] >= 10]

# ************* Average settlemt cost by gender *************
df2 = df[['gender', 'total_settlement']]
df2 = df2[df2['gender'] == 'F']
df3 = df[['gender', 'total_settlement']]
df3 = df3[df3['gender'] == 'M']
plt.bar(['Female','Male'], [np.int(df2.mean()), np.int(df3.mean())], color='red')
plt.title("Average settlement cost by gender")
plt.show()

# ************* Average settlemt cost by race *************

df4 = df[['race', 'total_settlement']]
df4 = df4[df4['race'] == 'White']

df5 = df[['race', 'total_settlement']]
df5 = df5[df5['race'] == 'Hispanic']

df6 = df[['race', 'total_settlement']]
df6 = df6[df6['race'] == 'Black']

df7 = df[['race', 'total_settlement']]
df7 = df7[df7['race'] == 'Asian/Pacific']

df8 = df[['race', 'total_settlement']]
df8 = df8[df8['race'] == 'Native American/Alaskan Native']

plt.bar(['White','Hispanic', 'Black', 'Asian/Pacific', 'Native American/Alaskan Native'], [np.int(df4.mean()), np.int(df5.mean()), np.int(df6.mean()), np.int(df7.mean()), np.int(df8.mean())], color='red')
plt.title("Average settlement cost by race")
plt.show()

# change total settlement value to its magnitude (e.g. 10 is 1, 100 is 2, 1000 is 3...)
df['total_settlement'] = df['total_settlement'].astype(int)
df['total_settlement'] = df['total_settlement'].transform(lambda x: np.round_(np.log10(x)))

# visualize class imbalance between settlement magnitudes
print(" *** Original class imbalance: ***")
print(df['total_settlement'].value_counts())
plt.title("Original Class Imbalance")
plt.bar(*zip(*df['total_settlement'].value_counts().items()))
plt.xlabel('Magnitude')
plt.ylabel('Frequency')
plt.show()


# Resample to fix imbalance
# class 5 is the majority class
class_3 = df[df['total_settlement'] == 3]
class_4 = df[df['total_settlement'] == 4]
class_5 = df[df['total_settlement'] == 5]
class_6 = df[df['total_settlement'] == 6]
class_7 = df[df['total_settlement'] == 7]
class_count_5, class_count_4, class_count_6, class_count_3, class_count_7 = df['total_settlement'].value_counts()
class_3_over = class_3.sample(class_count_5, replace=True)
class_4_over = class_4.sample(class_count_5, replace=True)
class_6_over = class_6.sample(class_count_5, replace=True)
class_7_over = class_7.sample(class_count_5, replace=True)
data_over = pd.concat([class_3_over, class_4_over, class_5, class_6_over, class_7_over], axis=0)

# split resampled data into input/output vectors
X = data_over[['interactions', 'outcomes', 'misconducts', 'gender', 'race']]
y = data_over[['total_settlement']]


# preprocess data to encode categorical data as numeric
le = preprocessing.LabelEncoder()
for column_name in X.columns:
    if X[column_name].dtype == object:
        X[column_name] = le.fit_transform(X[column_name])

# create model and run training and testing
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.20)
clf = RandomForestClassifier(n_estimators=10)
clf.fit(X_train, y_train)
y_pred = clf.predict(X_test)
scores = cross_val_score(clf, X, y, cv=5, scoring='accuracy') #try using 'accuracy', 'precision', 'recall', and 'f1_macro' for the scoring parameter
print("CV scores = ", scores)
print(metrics.classification_report(y_test, y_pred, digits=3))


