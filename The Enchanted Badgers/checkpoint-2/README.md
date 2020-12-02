# Checkpoint 2: Data Visualization

## Important Info

For this checkpoint, we needed to build and train a machine learning model to classify the complaints and the categories to which they belong. To this end, we put together code for building a bad of embeddings model and BERT transformer model with the AllenNLP framework, as well as how to pull down the necessary code, clean it, and prepare it for training the models. The code and instructions for doing that are contained in the `src/complaint_classifcation` directory.

Some of the visualizations we produce make use of the output from these classification models. We have included the classification results within that directory (entitled `uncategorized_results_boe.json` and `uncategorized_results_bert.json` for the bag of embeddings and BERT classifiers respectively). A detailed description of how we completed that entire process is including in the `findings.pdf` for this checkpoint. 

## Questions and How to View the Answers

To view the visualizations simply:
* open terminal and navigate to checkpoint 2 source file (e.g. checkpoint-2/src)
* start a python server with the following command: `python3 -m http.server`
* open a web browser and cut and paste the following URL: http://0.0.0.0:8000/

This will display the contents of the source directory in the web browser. Now simply click the visualization you want to view.

### Question 1: Horizontal bar chart to visualize the distribution of complaints

To view the visualization for question 1, click the *checkpoint2-q1.html* file

This will generate the following visualization:

![visualization 1](https://github.com/Northwestern-Data-Sci-Seminar/Invisible-Institute-Chicago-Reporter-Collaboration-Public/blob/enchanted-badgers/The%20Enchanted%20Badgers/checkpoint-2/screenshots/visualization1.png)

### Question 2: A grouped bar chart showing the classifications of uncategorized complaints using various language models

*Note: This question was originally "Stacked bar chart to visualize which category has the most uncategorized complaints, and what types of uncategorized complaints" in our project proposal, but was changed due to a lack of data. A more detailed explanation for this change is provided in the analysis for this question in the findings.pdf for this checkpoint.*

To view the visualization for question 2, click the *checkpoint2-q2.html* file

This will generate the following visualization:

![visualization 1](https://github.com/Northwestern-Data-Sci-Seminar/Invisible-Institute-Chicago-Reporter-Collaboration-Public/blob/enchanted-badgers/The%20Enchanted%20Badgers/checkpoint-2/screenshots/visualization2.png)

### Quesiton 3: Line chart to visualize the percentage of uncategorized complaints (year over year)

To view the visualization for question 3, click the *checkpoint2-q3.html* file

This will generate the following visualization:

![visualization 1](https://github.com/Northwestern-Data-Sci-Seminar/Invisible-Institute-Chicago-Reporter-Collaboration-Public/blob/enchanted-badgers/The%20Enchanted%20Badgers/checkpoint-2/screenshots/visualization3.png)

## Retrieving Datasets (Optional)
The datasets for the visualizations have already been provided, so you only need to run these queries if you want to verify the contents of the datasets. Note that these instructions apply for questions 1 and 3. The dataset for question 2 was generated using a transformer model as outlined in our findings.

### Method 1: Use PSQL

From within the `/src` directory you can use PSQL in order to interface with the remote AWS database using the following command.

`psql -f <QUESTION_FILENAME>.sql -h cpdb.cgod7egsd6vr.us-east-2.rds.amazonaws.com -U cpdb-student -d cpdb -p 5432`

and replacing <QUESTION_FILENAME> with the approriate query file name. For example, running the query for Question 1 would be as follows:

`psql -f Q1.sql -h cpdb.cgod7egsd6vr.us-east-2.rds.amazonaws.com -U cpdb-student -d cpdb -p 5432`

When prompted for a password, simply enter the password found within the setup instructions for Checkpoint 1 on Canvas (this is omitted here for security reasons).

### Method 2: DataGrip

In order to run these queries with DataGrip, you'll first need to make sure you have an active connection to the `cpdb` database. With that in place, simply open the `.sql` files in the `/src` directory and hit run. Alternatively, you can copy and paste the queries from the file into the DataGrip console and run them there.
