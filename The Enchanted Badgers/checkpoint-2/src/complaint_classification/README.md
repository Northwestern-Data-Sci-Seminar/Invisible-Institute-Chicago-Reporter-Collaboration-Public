## Setup

This code was tested using Python 3.7.5 on MacOS 10.15. Make sure you have installed the requirements using the following command (ideally in a new virtual environment):

`pip install -r requirements.txt`

## Downloading and Prepping the Necessary Data

Download the file from [here](https://github.com/invinst/documentAnalysis/blob/master/data/input/narratives.csv) as `narratives.csv` and place it in `src/complaint_classification/narrative_integration`

Download a dump of the `data_allegation` table as `data_allegation.csv` using the following SQL query against the CPDP database: `SELECT * FROM data_allegation`. You can use DataGrip download the results as a CSV file.

We then need to clean and integrate these narratives. For this, we will use the `narrative_cleaning_integration.py` script in the `src/complaint_classification/narrative_integration/` directory. From within that directory, run the following command:

```
python narrative_cleaning_integration.py
```
With the narratives cleaned and joined together, we need to put them into the database. You can do so with the following two SQL queries:

Create the table `data_narratives`:
```
CREATE TABLE data_narratives (
    id SERIAL,
    cr_id varchar(30),
    summary text,
    PRIMARY KEY (id)
);
```

Insert the data from `all_narratives.csv` into this table:

```
COPY data_narratives(cr_id, summary)
FROM '/full/path/to/all_narratives.csv'
DELIMITER ','
CSV HEADER;
```

Make sure to replace `/full/path/to/all_narratives.csv` with the actual path to the `all_narratives.csv` on you computer (keep the single quotes around it).

With all of the narratives now stored in our database, we can query the database for these narratives along with some of their associated data from other tables. To do this, run the following SQL query in DataGrip:

```
SELECT oa.allegation_id as allegation_id,
       oa.allegation_category_id as category_id,
       ac.category as category,
       oa.final_outcome as final_outcome,
       n.summary as summary
FROM data_officerallegation oa
    INNER JOIN data_allegationcategory ac on oa.allegation_category_id = ac.id
    INNER JOIN data_narratives n on oa.allegation_id = n.cr_id
WHERE n.summary > '';
```

Then, use DataGrip to download the results to a file called `complaints.json` in the `src/complaint_classification/data/raw/` directory.

We will now process this data into the form required for training the model with the following command. From the `src/complaint_classification/` directory, run:

```
python process_raw_data.py
```

Everything is now set up to train and use the models.

## Training the Model
Once the environment is set up and all of the training data is processed and available, a model can be trained using the provided jsonnet files by running a command in the terminal from the root directory of this set of files. For example:

```
allennlp train complaint_classifier_bag_of_embeddings.jsonnet -s boe_model --include-package complaint_classifier_module
```

Both scripts are set up to use a CPU for training by default. The bag of embeddings model will train quickly on a CPU, however the BERT model will not. If you have access to a CUDA compatible GPU, you can modify the `complaint_classifier_bert_base.jsonnet` file's line where it specifies the `"cuda_device": -1` to be `"cuda_device": 0` (meaning you'll use the first GPU available).

## Evaluating the Model (for testing purposes)
Then, to evaluate this model on the test dataset, use the following command in the terminal:

```
allennlp evaluate boe_model/model.tar.gz data/complaints/test_prepped.tsv --include-package complaint_classifier_module
```

## Classifying Unlabeled Data

We will need to first grab the unlabeled data from the database. From DataGrip, run the following SQL query to get the complaints that have a narrative/summary AND have a category label of 'Unknown' or NULL:

```
SELECT DISTINCT oa.allegation_id as allegation_id,
       oa.allegation_category_id as category_id,
       ac.category as category,
       n.summary as summary
FROM data_officerallegation oa
    LEFT JOIN data_allegationcategory ac on oa.allegation_category_id = ac.id
    LEFT JOIN data_narratives n on oa.allegation_id = n.cr_id
WHERE (ac.category = 'Unknown' OR ac.category IS NULL)
  AND n.summary > '';
```

Download the results of this query as a JSON file called `uncategorized_complaints.json` and put it in the `src/complaint_classifcation/uncategorized_integration/` directory. We will now process this data with the `process_uncategorized_data.py` script using the following command from the `src/complaint_classifcation/uncategorized_integration/` directory:

```
python process_uncategorized_data.py
```

This will produce a file called `formatted_uncategorized_complaints.json` which will be labeled/classified using the models we trained earlier. 

With the models properly trained and the unlabeled data pulled and processed, you can classify a dataset of unlabled/uncategorized complaints with the following command and script (from the base `complaint_classification` directory):

```
python classify_uncategorized_complaints.py path/to/model.tar.gz
```

You'll of course need to replace `path/to/model.tar.gz` with the proper file path. If you previously trained a bag of embeddings model using the commands above, you can use the following:

```
python classify_uncategorized_complaints.py boe_model/model.tar.gz
```

The result is a file called `uncategorized_results.json` which lists the categories and the total number of previous uncategorized complaints that were assigned to each category.


