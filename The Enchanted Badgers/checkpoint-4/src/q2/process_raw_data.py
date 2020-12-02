# Convert the JSON data file into separate and properly formatted .tsv files

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split

# Load the datafile in a Pandas DataFrame
df = pd.read_json(r'./data/raw/complaints.json')
# print(df.groupby('category').count())

# Change category to "other_outcome" if the number of samples for that category is less than a threshold
threshold = 5
new_category_name = "other_outcome"
df['outcome_counts'] = df['final_outcome'].map(df['final_outcome'].value_counts())

df.loc[df['outcome_counts'] < threshold, 'final_outcome'] = new_category_name
df = df.drop(['outcome_counts'], axis=1)

# Remove rows that have a NULL value or empty "final_outcome" value
# Trim whitespace from head and tail of the text
df['final_outcome'] = df['final_outcome'].str.strip()

# Remove rows where there is no value in the text column, or the value is "Unknown"
df = df[df['final_outcome'] != '']
df = df[df['final_outcome'] != 'Unknown']

# Bucket the suspension categories into "Short Term Suspension" (<= 30 days) and "Long Term Suspension" (> 30 days)
short_term = ['1 Day Suspension','10 Day Suspension','12 Day Suspension','15 Day Suspension','2 Day Suspension','20 Day Suspension', '25 Day Suspension','28 Day Suspension','3 Day Suspension','30 Day Suspension','4 Day Suspension','5 Day Suspension','6 Day Suspension','7 Day Suspension']
long_term = ['Suspended Over 30 Days','45 Day Suspension','60 Day Suspension','90 Day Suspension','120 Day Suspension','365 Day Suspension']

df.loc[df["final_outcome"].isin(short_term), "final_outcome"] = "Short Term Suspension"
df.loc[df["final_outcome"].isin(long_term), "final_outcome"] = "Long Term Suspension"

# Make sure the distribution of "final_outcome" classes is more balanced (taken from: https://stackoverflow.com/questions/45839316/pandas-balancing-data)
def sampling_k_elements(group, k=854):	# k is the max number of any final_outcome class
    if len(group) < k:
        return group
    return group.sample(k)
df = df.groupby('final_outcome').apply(sampling_k_elements).reset_index(drop=True)

# Create the sample arrays
summaries = df['summary'].to_numpy()
categories = df['category'].to_numpy()
outcomes = df['final_outcome'].to_numpy()

# Combine the categories and the summaries into a single string with special tokens surrounding the category
special_tokens = "@@"
cats_and_summaries_list = []
for idx in np.ndindex(summaries.shape[0]):
	formatted_text = special_tokens + categories[idx] + special_tokens + " " + summaries[idx]
	cats_and_summaries_list.append(formatted_text)
cats_and_summaries = np.array(cats_and_summaries_list)

# Display the number of samples associated with each unique type of "final_outcome"
print("Class distribution after balancing:")
unique_counts = np.array(np.unique(outcomes, return_counts=True)).T
print(unique_counts)
print(len(outcomes))

# Split the data into a 60/20/20 train/validation/test split (making sure the samples are balanced across final outcome classes)
x_train, x_test, y_train, y_test = train_test_split(cats_and_summaries, outcomes, test_size=0.2, stratify=outcomes)

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
