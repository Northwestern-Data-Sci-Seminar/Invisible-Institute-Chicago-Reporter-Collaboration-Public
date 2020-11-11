## Setup

This code was tested using Python 3.7.5. Make sure you have installed the requirements using the following command (ideally in a new virtual environment):

`pip install -r requirements.txt`


## Processing the Raw Data

We will now process this data into the form required for training the model with the following command. From the `src/q2/` directory, run:

```
python process_raw_data.py
```

This will use the data from `src/q2/raw/complaints.json` to create the properly cleaned and formatted datasets for training and evaluating the classification models. These resulting .tsv files will be in the `src/q2/complaints/` directory if you would like to see the output.

## Training and Evaluating the Models

Once the environment is set up, a model can be trained using the provided jsonnet files by running a command in the terminal from the root directory of this set of files. For example:

```
allennlp train complaint_classifier_bag_of_embeddings.jsonnet -s boe_model --include-package complaint_classifier_module
```

Both scripts are set up to use a CPU for training by default. The bag of embeddings model will train quickly on a CPU, however the BERT model will not. If you have access to a CUDA compatible GPU, you can modify the `complaint_classifier_bert_base.jsonnet` file's line where it specifies the `"cuda_device": -1` to be `"cuda_device": 0` (meaning you'll use the first GPU available).

Then, to evaluate this model on the test dataset, use the following command in the terminal:

```
allennlp evaluate boe_model/model.tar.gz data/complaints/test_prepped.tsv --include-package complaint_classifier_module
```

A set of metrics and accuracy output will be viewable as output in the terminal. A full analysis of the results can be found in the `findings.pdf` document for Checkpoint 4.