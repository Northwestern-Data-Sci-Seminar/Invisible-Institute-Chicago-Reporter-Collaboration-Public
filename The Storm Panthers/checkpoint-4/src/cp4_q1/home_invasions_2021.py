import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import sklearn
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from scipy import stats

# to run this file, run `pythonw home_invasions_2021.py` in your terminal once you have navigated to the cp4_q1 folder

home_invasions_per_year = pd.read_csv("home_invasions_per_year.csv", header=None)
# check it out:
print("Number of home invasion allegations per year: ", home_invasions_per_year)

# plot our data to get a feel for it:
fig = plt.figure()
plt.title('Number of Home Invasion Allegations Per Year')
plt.xlabel('Year')
plt.ylabel('Count')
plt.scatter(home_invasions_per_year.loc[:, 0], home_invasions_per_year.loc[:, 1])
txt = "FIGURE 1: This is the complete set of our data. It presents the total number of home invasion allegations for " \
      "each of the years for which we have data"
fig.text(.5, -.1, txt, ha='center')
plt.show()

# check for outliers:
print("Though the scatterplot may visually suggest that we could have outliers, "
      "there are not any outliers for us to remove, according to both Z-Score and IQR methods")

print("We can check the IQR results visually by creating a box plot. As you can see,"
      " no points fall outside of the quartiles")
sns.boxplot(x=home_invasions_per_year.loc[:, 1])

# prep data for regression
X = home_invasions_per_year.loc[:,0]
y = home_invasions_per_year.loc[:,1]
# reshape X array since it contains a single feature:
X = X.values.reshape(-1, 1)

# create and fit the model
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, train_size=0.8, random_state=1)
model = LinearRegression()
model.fit(X_train, y_train)

# now, use our model to predict the # of home invasion allegations in 2021:

# create a single sample array:
predict_this = pd.Series(2021)
# reshape:
predict_this = predict_this.values.reshape(1, -1)
# predict:
prediction_2021 = model.predict(predict_this)
print("Predicted # of home invasion allegations in 2021:", prediction_2021)







