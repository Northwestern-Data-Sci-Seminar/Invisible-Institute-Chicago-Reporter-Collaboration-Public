# Convert the JSON data file into separate and properly formatted .tsv files

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split

# Load the datafile in a Pandas DataFrame
df = pd.read_json(r'./data/raw/complaints.json')
print(df.groupby('category').count())

# Change category to "other_category" if the number of samples for that category is less than a threshold
threshold = 5
new_category_name = "other_category"
df['category_counts'] = df['category'].map(df['category'].value_counts())

df.loc[df['category_counts'] < threshold, 'category'] = new_category_name
df = df.drop(['category_counts'], axis=1)

# Create the sample arrays
summaries = df['summary'].to_numpy()
classes = df['category'].to_numpy()


# Split the data into a 60/20/20 train/validation/test split (making sure the samples are balanced across classes)
x_train, x_test, y_train, y_test = train_test_split(summaries, classes, test_size=0.2, stratify=classes)

# Split the train set into train and validation set
x_train, x_valid, y_train, y_valid = train_test_split(x_train, y_train, test_size=0.2, stratify=y_train)

# Write out the tsv files, according to the trian/validation/test splits
train_file = open("data/complaints/train_prepped.tsv", "w")
validation_file = open("data/complaints/valid_prepped.tsv", "w")
test_file = open("data/complaints/test_prepped.tsv", "w")

for idx in range(x_train.shape[0]):
	train_file.write(x_train[idx] + "\t" + y_train[idx] + "\n")

for idx in range(x_valid.shape[0]):
	validation_file.write(x_valid[idx] + "\t" + y_valid[idx] + "\n")

for idx in range(x_test.shape[0]):
	test_file.write(x_test[idx] + "\t" + y_test[idx] + "\n")

# Cleanup
train_file.close()
validation_file.close()
test_file.close()
