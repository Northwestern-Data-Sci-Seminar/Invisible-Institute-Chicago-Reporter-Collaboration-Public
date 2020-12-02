## Questions
1. Can we classify verbal abuse, profanity, and offensive remarks in complaint report narratives?
2. How can we relate these verbal abuse classifications to other officer characteristics?

## Data
The CPDP data for this checkpoint can be acquired from running the query in the file 'src/cp5.sql'. We used datagrip to run the query on the CPDP data. Then, we exported the query result into a csv file, including column headers. The query is exported to 'data_allegation_summaries.csv'. 

We also manually created a list of keywords used for identifying verbal abuse in the summaries. These keywords can be found in 'keywords.csv'. 

We had to pseudo manually tag the summaries regarding whether they contained verbal abuse or not. The Python script 'tagging_data.py' exports the tagged data to 'verbal_abuse.csv'. This csv file is loaded into 'train_test.py' for creating and testing our classifier.  

## Python Code and NLP Model
We wrote the code using Python 3.7. All required packages and versions are in the file 'src/requirements.txt'. All used files are under the 'src' folder. Once all required packages have been installed and your Python environment is set up, first run the Python file 'tagging_data.py'; this will manually tag summaries regarding whether they contain verbal abuse or not. Then run 'train_test.py' to create, train, and test our classifier. The model is then serialized and exported to the file 'finalized_model.sav'. After, run 'data_analytics.py' to explore how verbal abuse relates to certain officer characteristics. Make sure the csv files are in the same directory as the Python file. When you run the code, figures will pop up in a new window. You need to close the figure window for the code to procceed. We also print out to the console information about the data and our model evaluations. 

The serialized and exported model is also available in the main checkpoint 5 directory under 'model.sav'. The model was exported and can be imported using Python pickle. This can be seen in 'src/train_test.py'. 

