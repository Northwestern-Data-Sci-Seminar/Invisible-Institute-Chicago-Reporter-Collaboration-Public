## Questions
1. Can we predict whether an allegation would lead to discipline based on officer and allegation data?
2. Can we predict the settlement amount (magnitude) of an allegation lawsuit based on officer and allegation characteristics?

## Data
The data for this checkpoint can be acquired from running the two queries in the file 'src/cp4_query'. There are two queries in that file for the two questions we answer in this checkpoint. We used datagrip to run these queries on the CPDP data. Then, we exported each query result into csv files, including column headers. The query for question 1 is exported to 'cp4_data_all.csv'. The query for question 2 is exported to 'cp4_question_2_predict_settlement_amount.csv'. 

## Python Code
We wrote the code using Python 3.7. All required packages and versions are in the file 'src/requirements.txt'. Once all required packages have been installed and your Python environment is set up, run the Python file 'cp4_ml.py'. Make sure the csv files are in the same directory as the Python file. When you run the code, figures will pop up in a new window. You need to close the figure window for the code to procceed. We also print out to the console information about the data and our model evaluations. 

