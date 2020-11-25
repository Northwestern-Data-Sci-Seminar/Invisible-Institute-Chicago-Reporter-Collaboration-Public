# Clean and integrate the narratives/summaries from the data_allegation table and narratives.csv

import pandas as pd

################################################################
# Clean up the narratives.csv file
################################################################
# Read in the narratives.csv file into a dataframe
nar_df = pd.read_csv(r'narratives.csv',
                     usecols=['cr_id', 'column_name', 'text'],
                     dtype={"cr_id": "string", "column_name": "string", "text": "string"})

# Remove rows where 'column_name' is not in {'Initial / Intake Allegation', 'Allegation'}
nar_df = nar_df[nar_df['column_name'].isin(['Initial / Intake Allegation', 'Allegation'])]
print(len(nar_df.index))  # The result should be 31,572 rows of data

# Set to text to '' where text = {'(None entered)', 'NO AFFIDAVIT'}
nar_df['text'] = nar_df['text'].replace(['(None entered)', 'NO AFFIDAVIT'], '')

# Replace carriage returns in text with spaces
nar_df['text'] = nar_df['text'].str.replace('\\n', ' ')
nar_df['text'] = nar_df['text'].str.replace('\\r', ' ')

# Trim whitespace from head and tail of the text
nar_df['text'] = nar_df['text'].str.strip()

# Remove rows where there is no value in the text column
nar_df = nar_df[nar_df['text'] != '']

# Remove duplicate summaries for a single allegation id (heuristic: take the one with the longer narrative text)
nar_df = nar_df.sort_values('text').drop_duplicates('cr_id', keep='last')
nar_df = nar_df.sort_values('cr_id')
print(len(nar_df.index))  # The result should be 14900 rows of data

################################################################
# Load the necessary data from data_allegation and clean it
################################################################
allegation_df = pd.read_csv(r'data_allegation.csv',
                            usecols=['crid', 'summary'],
                            dtype={"crid": "string", "summary": "string"})

# Replace all null summaries with empty strings
allegation_df.summary.fillna('', inplace=True)
print(len(allegation_df.index))  # The result should be 14900 rows of data

################################################################
# Integrate the two cleaned datasets
################################################################

# Pull out the needed columns and rename them to align with the allegation_df
subset_nar_df = nar_df[['cr_id', 'text']]
subset_nar_df =  subset_nar_df.rename(columns={"cr_id": "crid", "text": "summary"})
print(len(subset_nar_df.index))  # The result should be 14900 rows of data

# Concatenate the two datasets
final_df = pd.concat([allegation_df, subset_nar_df], ignore_index=True)
print(len(final_df.index))  # The result should be 230952 rows of data

# Remove duplicate summaries for a single allegation id (heuristic: take the one with the longer narrative text)
final_df = final_df.sort_values('summary').drop_duplicates('crid', keep='last')
final_df = final_df.sort_values('crid')
print(len(final_df.index))  # The result should be 216060 rows of data

# Remove rows where there is no value in the summary column
final_df = final_df[final_df['summary'] != '']
final_df.reset_index()
print(len(final_df.index))  # The result should be 16010 rows of data

################################################################
# Write out the final csv file with the header
################################################################
output_file = open("all_narratives.csv", "w")
final_df.to_csv(output_file, index=False)
