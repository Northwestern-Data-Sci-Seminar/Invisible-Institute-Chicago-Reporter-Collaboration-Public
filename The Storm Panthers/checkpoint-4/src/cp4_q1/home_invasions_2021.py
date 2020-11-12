import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import sklearn
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from scipy import stats

# Navigate to src/cp4_q1 in your terminal
# Run `pip install -r requirements.txt`
# Then, run `pythonw home_invasions_2021.py`
# Note: To walk through all plots and output printed to the terminal, you will need to close the current plot to continue on.

home_invasions_per_year = pd.read_csv("home_invasions_per_year.csv", header=None)

print('\n')
print("FIGURE 1: This is the complete set of our data. It presents the total number of home invasion allegations for " \
      "each of the years for which we have data")
print('\n')

# check it out:
print("Number of home invasion allegations per year: ", home_invasions_per_year)
print('\n')

# plot our data to get a feel for it:
fig = plt.figure()
plt.title('FIGURE 1: Number of Home Invasion Allegations Per Year')
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
print('\n')

# Z-SCORE METHOD:
# convert our pandas series to a numpy array
home_invasions_per_year_np = np.array(home_invasions_per_year)

outliers = []
z_scores = np.empty((home_invasions_per_year_np.shape[0]))

def detect_outlier(data_1):
      threshold = 3
      mean_1 = np.mean(data_1)
      std_1 = np.std(data_1)

      for y in range(0, data_1.shape[0]):
            z_score = (y - mean_1) / std_1
            z_scores[y] = z_score
            if np.abs(z_score) > threshold:
                  outliers.append(y)
      return z_scores

print("If any of the absolute values of the z-scores were > 3, that would be an outlier. We do not have any instances of this, as you can see: ", '\n', detect_outlier(home_invasions_per_year_np))
print('\n')

print("We can check the IQR results visually by creating a box plot. As you can see,"
      " no points fall outside of the quartiles")
print('\n')
outlier_boxplot = sns.boxplot(x=home_invasions_per_year.loc[:, 1])
outlier_boxplot.set_title('FIGURE 2: Visual check for outliers')
outlier_boxplot.set_xlabel('Number of home invasion allegations per year')
plt.show()


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
print('\n')


# what's the accuracy of our model?
predictions_test_accuracy = model.predict(X_train)

params = np.append(model.intercept_,model.coef_)
newX = np.append(np.ones((len(X_train),1)), X_train, axis=1)
MSE = (sum((y_train-predictions_test_accuracy)**2))/(len(newX)-len(newX[0]))

var_b = MSE*(np.linalg.inv(np.dot(newX.T,newX)).diagonal())
sd_b = np.sqrt(var_b)
ts_b = params/ sd_b

p_values =[2*(1-stats.t.cdf(np.abs(i),(len(newX)-len(newX[0])))) for i in ts_b]

sd_b = np.round(sd_b,3)
ts_b = np.round(ts_b,3)
p_values = np.round(p_values,3)
params = np.round(params,4)

regression_results = pd.DataFrame()
regression_results["Coefficients"],regression_results["Standard Errors"],regression_results["t values"],regression_results["p values"] = [params,sd_b,ts_b,p_values]
print("Accuracy of our model based on training data: ", regression_results)


print("This marks the end of Checkpoint 4, Question 1. Thank you for following along. Go 'cats!")
print('\n')







