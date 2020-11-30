# import packages
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVC, LinearSVC, NuSVC
from sklearn.metrics import accuracy_score, classification_report
from sklearn.metrics import plot_confusion_matrix

# import data and combine to make binary independent variable (whether or not an officer participated in a home invasion complaint)
home_invasion_officers = pd.read_csv("home_invasions_officers.csv")
non_home_invasion_officers = pd.read_csv("non_home_invasion_officers.csv")
home_invasion_officers["home_invasion"] = 1
non_home_invasion_officers["home_invasion"] = 0
frames = [home_invasion_officers, non_home_invasion_officers]
officers = pd.concat(frames)

# one hot encoding: for gender, race, and active status
numerical_officers = officers
one_hot_gender = pd.get_dummies(numerical_officers.gender)
one_hot_race = pd.get_dummies(numerical_officers.race)
one_hot_active = pd.get_dummies(numerical_officers.active)
numerical_officers = officers[['birth_year', 'honorable_mention_count',
                         'trr_count', 'sustained_count', 'civilian_compliment_count',
                         'discipline_count']].copy()
numerical_officers['female'] = one_hot_gender['F']
numerical_officers['male'] = one_hot_gender['M']
numerical_officers['Asian/Pacific'] = one_hot_race['Asian/Pacific']
numerical_officers['Black'] = one_hot_race['Black']
numerical_officers['Hispanic'] = one_hot_race['Hispanic']
numerical_officers['Native American/Alaskan Native'] = one_hot_race['Native American/Alaskan Native']
numerical_officers['Unknown_Race'] = one_hot_race['Unknown']
numerical_officers['White'] = one_hot_race['White']
numerical_officers['Active'] = one_hot_active['Yes']
numerical_officers['Inactive'] = one_hot_active['No']
numerical_officers['Unknown_Active'] = one_hot_active['Unknown']

# Set up data for ML modeling
y = officers["home_invasion"].to_numpy()
X = numerical_officers.to_numpy()
X_train, X_test, y_train, y_test = train_test_split(
     X, y, test_size=0.2, random_state=42)
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)

# Create and evaluate a Linear SVC model
LSVC = LinearSVC(max_iter = 10000, dual=False)
LSVC.fit(X_train, y_train)
y_test_LSVC_model = LSVC.predict(X_test)
print("LSVC Accuracy :", accuracy_score(y_test, y_test_LSVC_model))
plt.figure(figsize=(20,20))
plot_confusion_matrix(LSVC, X_test, y_test)
plt.show()
