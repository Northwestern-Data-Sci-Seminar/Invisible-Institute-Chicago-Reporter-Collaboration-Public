# Checkpoint 4: Machine Learning

For our machine learning checkpoint we looked at the following question:

For officers with sustained allegations, can we predict the percent change in pay for an officer in a given year, given a number of variables such as whether the officer has had multiple previous sustained allegations, officer type, unit, race of officer, gender of officer, age of officer?

We followed 2 approaches:
- Approach 1: As a regression problem
- Approach 2: As a time series problem

Directories:
* `src` contains the SQL scripts to obtain the csv data and the notebooks for each approach.
    * Script: `checkpoint_4_data.sql`
    * Notebook for approach 1 : `checkpoint_4_catboost.ipynb`
    * Notebook for approach 2 : `checkpoint_4_time_series.ipynb`
* `data` contains the csv data: `checkpoint_4_data.csv`
* `findings.pdf` contains our report
