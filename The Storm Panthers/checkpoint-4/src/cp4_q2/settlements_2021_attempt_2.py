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

data_ar = df.to_numpy()
examples = data_ar[:,1].reshape(-1,1)
targets = data_ar[:,-1]

# train_examples, test_examples, train_labels, test_labels = train_test_split(examples, targets, test_size=0.2, train_size=0.8, random_state=1)
model = LinearRegression()
model.fit(examples, targets)
print("train data", examples)
print("train labels", targets)

print(model.coef_, model.intercept_)

x_new = np.linspace(0, 350, 100)
y_new = model.predict(x_new[:, np.newaxis])
df.plot.scatter(x='count', y='sum')
plt.plot(x_new, y_new)
plt.xlabel('Number of Allegations')
plt.ylabel('Total Settlements')
plt.show()
plt.clf()

new_target = np.array([[18]])
prediction = model.predict(new_target)
print("Predicted:", prediction)
# print('\n')
