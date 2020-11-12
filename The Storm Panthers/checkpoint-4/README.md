## Question 1


## Question 2


## Question 3

We sought to answer the question "Can we predict which officers will be implicated in Home Invasion complaints?"

### Running the code
Use the command `pythonw cp4_q3.py` to run.

### Procedure
The relevant information here was obtained using the SQL queries present in c4_q3.sql and includes information about officers who either were or were not involved in at least one home invasion complaint. 

From there, this data was combined into a single Pandas dataframe with a column for home_invasion, where a 0 signified no participation in a home invasion complaint and a 1 signified participation in such a complaint.

In order to use the data in a machine learning model, some of the categorical data needed to be converted into numerical data. Specifically, officer race, gender, and whether or not they are active had distinct non-numerical labels. Because there is no logical progression of these things, (Black is not < or > Hispanic), we used One Hot Encoding for these categories. The other dependent variables included were birthyear, honorable mention count, trr count, sustained count, civilian compliment count, and discipline count. These variables were already numerical and did not seem to significantly overlap conceptually.

From there, this data was scaled and fit to a LinearSVC model with default settings. The accuracy and confusion matrix of the model are outputted.

### Other attempts

You can view other work in the jupyter notebook "Question 3 - Predicting Officers in Home Invasion Complaints". We tried several models, including GaussianNB, KNeighborsClassifier, MultinomialNB, BernoulliNB, LogisticRegression, SGDClassifier, SVC, and NuSVC. The only one that performed as well as LinearSVC was the Stochastic Gradient Descent classifier, but nearly all models performed similarly with the exception of K-Nearest Neighbors which underperformed. 

We also used GridSearchCV to search for the optimal parameters. It turned out that the default was actually the most effective, so no changes were made on that front.

### Results

This model does better than chance with predicting which officers are involved in Home Invasion complaints, but not much better. This model (and indeed all models tested) does poorly with accurately identifying officers who were involved in Home Invasions, with more false positives than true positives. The model's accuracy is .608.

