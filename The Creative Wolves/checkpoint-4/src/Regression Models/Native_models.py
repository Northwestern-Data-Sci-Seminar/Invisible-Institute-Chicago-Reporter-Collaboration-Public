import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import cross_val_score, GridSearchCV
from sklearn.metrics import accuracy_score, confusion_matrix
from sklearn.ensemble import GradientBoostingRegressor

data_path = "./data.csv"

# import data + initial cleaning
def load_data(path = data_path):
    df = pd.read_csv(path)
    df2 = pd.get_dummies(df, columns=["gender", "race", "rank"])  
    df2 = df2.dropna()
    X = df2.drop(["id", "allegation_count", "salary", "number_of_awards"], axis = 1)
    y = df2["allegation_count"]
    return X, y


# create model
def createLinearRegressionModel(X, y):

    #model creation
    regModel = LinearRegression()
   
    #trainning model
    cv_scores = cross_val_score(regModel, X, y, cv = 5, scoring = "r2") 
    print(cv_scores)
    print("Linear Regression (without salary and num_awards)  average 5-fold CV R2 score: {}".format(np.mean(cv_scores)))

    #testing model



#GBT Regressor
def createGBTModel(X, y):
    GBTModel = GradientBoostingRegressor()
    cv_scores = cross_val_score(GBTModel, X, y, cv = 5,scoring = "r2") 
    print(cv_scores)
    print("GBT Regression (without salary and num_awards) average 5-fold CV R2 score: {}".format(np.mean(cv_scores)))

    n_estimators_space = [100,200] 
    learningrate_space = [0.1,0.2]
    depth_space = [3,5]
    param_grid = {
        "learning_rate" : learningrate_space, "n_estimators" : n_estimators_space, "max_depth" : depth_space
    }
    GBT_cv = GridSearchCV(GBTModel, param_grid, cv = 5, scoring = "r2") 
    GBT_cv.fit(X, y)
    print("Best parameters are: {}".format(GBT_cv.best_params_)) 
    print("Best score is: {}".format(GBT_cv.best_score_))



#run the pipeline
X, y = load_data(data_path)
createLinearRegressionModel(X, y)
createGBTModel(X, y)

