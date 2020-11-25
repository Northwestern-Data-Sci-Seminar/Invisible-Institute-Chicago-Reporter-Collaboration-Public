# Convert the JSON data file into separate and properly formatted .json file for use with the AllenNLP predictor

import pandas as pd
import json

# Load the datafile in a Pandas DataFrame
df = pd.read_json(r'./uncategorized_complaints.json')

# Filter out unneeded values
df = df[['summary']]

# Rename the column
df = df.rename(columns={"summary": "sentence"})

# Write out the json file, according to the input format required in "complaint_classifier_module/predictors/sentence_classifier_predictor.py"
sample_file = open("formatted_uncategorized_complaints.json", "w")

for x in df['sentence']:
    output = {"sentence": x}
    sample_file.write(json.dumps(output) + "\n")

# Cleanup
sample_file.close()
