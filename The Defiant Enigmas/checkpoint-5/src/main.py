import get_data
import get_results

import numpy as np
import pandas as pd
import spacy


nlp = spacy.load('en_core_web_lg')

results_df = get_data.get_data()

list_of_summaries = results_df.loc[:,'summary'].values.tolist()
list_of_allegation_categories = results_df.loc[:, 'most_common_category'].values

y = results_df.loc[:,'sustained'].values

vectors = np.array([nlp(row['summary']).vector for i, row in results_df.iterrows()])
#results_df['summ_vec'] = vectors.tolist()

print("\nAllegation features without summaries:")
features_no_summary = results_df.loc[:, results_df.columns.difference(['crid', 'summary', 'sustained', 'most_common_category'])].fillna(0).values
get_results.results(features_no_summary,
                    y,
                    list_of_summaries,
                    list_of_allegation_categories,
                    5)

print("\nSummary embeddings only:")
get_results.results(vectors, y, list_of_summaries, list_of_allegation_categories, 4)

print("\nAllegation features with summary embeddings:")
get_results.results(np.hstack((features_no_summary, vectors)), y, list_of_summaries, list_of_allegation_categories, 5)
