## Question 1

We sought to answer the question "How many home invasions and illegal searches can we expect in 2021 if there is no policy change?"

### Running the code

* Navigate to `src/cp4_q1` in your terminal
* Run `pip install -r requirements.txt`
* Use the command `pythonw home_invasions_2021.py` to run the code.
* Note: To walk through all plots and output printed to the terminal, you will need to close the current plot to continue on.

### Results, in brief
The predicted number of home invasion allegations in 2021 is 18.

## Question 2
With this question we wanted to learn how much lawsuit settlements connected to home invasions were likely to cost the police department next year if nothing changes.

### Assumptions
* We are defining the "cost to the police department per year" as the cost from all lawsuits that are likely to be filed based on incidents that happened in that year.  This will capture the cost of not changing policies, as left over settlements from previous years will happen regardless of policy changes.
* We are excluding data from before the year 2000.  We are interested in predicting current trends so older data is less relevant, and prior to 2000 the data relating to home invasions is very sparse.  It would be interesting to examine why that is, but for this question we are ignoring those datapoints.  We are also ignoring settlement data from 2019, as we don't have allegations from after 2018.
* For calculating yearly cost totals, we are including any settlements with a location of "Home Invasion".  While the settlements will undoubtedly include other charges, if the incident happened during a home invasion we can count that as relating to this policy.

### Preparation
Since settlements take a few years to close, we chose to estimate the likely eventual total costs per year based on average times to close.   If we assume that settlement times will follow a normal distribution, we can estimate the eventual cost for a year by dividing the current total cost from that year by the proportion of settlements that have likely completed.  The latter value can be calculated from the z-score of the time between the midpoint of a year and the date this database was last updated (2020-09-01), from the distribution of settlement times.

The mean settlement time (time between "incident date" and "paid date") for home invasion lawsuits is 3.72 years, with a standard deviation of 2.30 years.  Note that this is likely an underestimate, as shorted settlement times will be overrepresented in our database (they have had time to complete). Using that, the year 2017 for example would have a z-value of .20.

We extracted the settlement totals for each year between 2000 and 2018 along with assiciated z-scores using query cp4_q2a.sql, and the total allegations relating to home invasions over the same period using query cp4_q2b.sql.

### Attempt 1:
We used the allegation counts and settlement estimates to build a multivariate regression model, where year and allegation count are used to predict the overall settlement total for a given year. The intention was to build a prediction using the year 2021, and the total predicted allegations from question 1 (18).

The problem was that although allegation counts show a pretty linear relationship, settlements vary wildly.  As a result, our model generated a very steep hyper-plane, which predicted a settlement total for 2021 of -$700,000.  This is clearly wrong.

If you run settlements_2021_attempt_1.py you will see the plots of allegation counts and settlements vs year.  The 3d scatterplot shows why our hyper-plane ended up very vertical.

### Attempt 2:
We next tried building a linear regression model just from allegation counts and associated settlement totals (one datapoint per year).  This ran into a similar problem however, and since settlements vary so dramatically the generated regression line was essentially flat.

This predicted a settlement total for 2021 of $4,729,701, but this is also highly unreliable, as these 2 parameters appear poorly correlated.

### Final Attempt

We decided that the best approach for this was question was not to build another model at all, but instead find the average settlement amount per home-invasion allegation from the full dataset, and multiply that by the results from the model in question 1.

This gave us a predicted settlement total for 2021 of $626,610.

## Question 3

We sought to answer the question "Can we predict which officers will be implicated in Home Invasion complaints?"

### Running the code
* Navigate to `src/cp4_q3` in your terminal
* Use the command `pythonw cp4_q3.py` to run the code.

### Procedure
The relevant information here was obtained using the SQL queries present in c4_q3.sql and includes information about officers who either were or were not involved in at least one home invasion complaint. 

From there, this data was combined into a single Pandas dataframe with a column for home_invasion, where a 0 signified no participation in a home invasion complaint and a 1 signified participation in such a complaint.

In order to use the data in a machine learning model, some of the categorical data needed to be converted into numerical data. Specifically, officer race, gender, and whether or not they are active had distinct non-numerical labels. Because there is no logical progression of these things, (Black is not < or > Hispanic), we used One Hot Encoding for these categories. The other dependent variables included were birthyear, honorable mention count, trr count, sustained count, civilian compliment count, and discipline count. These variables were already numerical and did not seem to significantly overlap conceptually.

From there, this data was scaled and fit to a LinearSVC model with default settings. The accuracy and confusion matrix of the model are outputted.

### Other attempts

You can view other work in the jupyter notebook "Question 3 - Predicting Officers in Home Invasion Complaints". We tried several models, including GaussianNB, KNeighborsClassifier, MultinomialNB, BernoulliNB, LogisticRegression, SGDClassifier, SVC, and NuSVC. The only one that performed as well as LinearSVC was the Stochastic Gradient Descent classifier, but nearly all models performed similarly with the exception of K-Nearest Neighbors which underperformed. 

We also used GridSearchCV to search for the optimal parameters. It turned out that the default was actually the most effective, so no changes were made on that front.

We tried balancing the datasets as well, but accuracy dropped by 20%, probably due to the loss of so much data.
### Results

This model does better than chance with predicting which officers are involved in Home Invasion complaints, but not much better. This model (and indeed all models tested) does poorly with accurately identifying officers who were involved in Home Invasions, with more false positives than true positives. The model's accuracy is .801.

