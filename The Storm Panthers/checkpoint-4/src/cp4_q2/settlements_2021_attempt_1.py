import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from scipy import stats as st

settlements_by_year = pd.read_csv("settlements_by_year.csv", index_col='incident_year')
home_invasions_by_year = pd.read_csv("home_invasions_by_year.csv", index_col='incident_year')
df = pd.concat([home_invasions_by_year, settlements_by_year], axis=1, join='inner').sort_index().reset_index()
for year, values in df.iterrows():
    z_tab = st.norm.cdf(values['z_score'])
    df.at[year,'sum'] = values['sum'] / z_tab
df.drop('z_score', axis=1, inplace=True)

df.plot.scatter(x='incident_year', y='count')
plt.ylabel('Number of Allegations')
plt.show()
plt.clf()

df.plot.scatter(x='incident_year', y='sum')
plt.ylabel('Total Settlements')
plt.show()
plt.clf()

data_ar = df.to_numpy()
examples = data_ar[:,0:-1]
targets = data_ar[:,-1]

fig = plt.figure()
ax = plt.axes(projection="3d")
z_points = data_ar[:,2]
x_points = data_ar[:,1]
y_points = data_ar[:,0]
ax.scatter3D(x_points, y_points, z_points, c=z_points, cmap='hsv');
plt.show()
plt.clf()


# train_examples, test_examples, train_labels, test_labels = train_test_split(examples, targets, test_size=0.2, train_size=0.8, random_state=1)
model = LinearRegression()
model.fit(examples, targets)
# print("train data", train_examples)
# print("train labels", train_labels)

new_target = np.array([[2021, 18]])
prediction = model.predict(new_target)
print("Predicted settlements in 2021:", prediction)
# print('\n')
