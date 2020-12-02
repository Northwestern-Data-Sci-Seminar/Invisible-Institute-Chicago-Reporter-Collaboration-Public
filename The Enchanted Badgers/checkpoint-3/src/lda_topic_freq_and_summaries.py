import pandas as pd
import os
import json
import re
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.decomposition import LatentDirichletAllocation as LDA
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
import spacy
import en_core_web_lg
import pickle

def main():
    warnings.simplefilter('ignore', DeprecationWarning)
    sns.set_style('whitegrid')

    #make pd df from allegation summaries
    summary_file = open('data/raw/complaints.json', encoding = "utf8")
    summary_file_uncategorized = open('uncategorized_integration/uncategorized_complaints.json', encoding = "utf8")
    summary_data = json.load(summary_file)
    summary_data_uncategorized = json.load(summary_file_uncategorized)
    summary_file.close()
    summaries = []
    summaries_uncategorized = []
    summaries_with_outcome = []
    summaries_with_outcome_uncategorized = []

    en_core = spacy.load('en_core_web_lg')

    for dicts in summary_data:
        summaries.append(dicts["summary"])
        

    for dicts in summary_data_uncategorized:
        summaries_uncategorized.append(dicts["summary"])

    for dicts in summary_data:
        summaries_with_outcome.append((dicts["summary"], dicts["category"]))

    for dicts in summary_data_uncategorized:
        summaries_with_outcome_uncategorized.append((dicts["summary"], "Uncategorized"))

    summary_df = pd.DataFrame(summaries, columns=['summary'])

    summary_uncategorized_df = pd.DataFrame(summaries_uncategorized, columns=['summary'])

    stopwords = set(['cook county','chicago','allegedly','po','ofcer','sergeant','ipra','detective','accused', 'officer', 'officers', 'reporting', 'party', 'alleged', 'alleges', 'complainant', 'victim', 'police', '-pron-', 'pron', '-PRON-', '[-PRON-]', 'allege', 'accuse', 'report'])

    #remove punctuation
    summary_df['summary_text_processed1'] = summary_df['summary'].map(lambda x: re.sub('[,\.!?]()', '', x))
    summary_uncategorized_df['summary_text_processed1'] = summary_df['summary'].map(lambda x: re.sub('[,\.!?]()', '', x))

    #convert to lower
    summary_df['summary_text_processed2'] = summary_df['summary_text_processed1'].map(lambda x: x.lower())
    summary_uncategorized_df['summary_text_processed2'] = summary_df['summary_text_processed1'].map(lambda x: x.lower())

    #lemmatize
    summary_df['summary_text_processed3'] = summary_df['summary_text_processed2'].map(lambda x: " ".join([y.lemma_ for y in en_core(x)]))
    summary_uncategorized_df['summary_text_processed3'] = summary_df['summary_text_processed2'].map(lambda x: " ".join([y.lemma_ for y in en_core(x)]))

    #remove years
    summary_df['summary_text_processed4'] = summary_df['summary_text_processed3'].map(lambda x: re.sub('(19|20)[0-9][0-9]', '', x))
    summary_uncategorized_df['summary_text_processed4'] = summary_df['summary_text_processed3'].map(lambda x: re.sub('(19|20)[0-9][0-9]', '', x))

    #remove stopwords
    summary_df['summary_text_processed'] = summary_df['summary_text_processed4'].map(lambda x: " ".join([item for item in x.split() if item not in stopwords]))
    summary_uncategorized_df['summary_text_processed'] = summary_df['summary_text_processed4'].map(lambda x: " ".join([item for item in x.split() if item not in stopwords]))

    # Initialise the count vectorizer with the English stop words
    count_vectorizer = CountVectorizer(stop_words='english')

    print(len(summary_df))

    # Fit and transform the processed titles
    count_data = count_vectorizer.fit_transform(summary_df['summary_text_processed'])


    for iteration in range(10):

        number_topics = 20
        number_words = 12

        filename = 'lda_model_iteration_'+str(iteration)+'_topics_'+str(number_topics)+'_words_'+str(number_words)

        filename_sav = filename+'.sav'

        model = pickle.load(open('lda_models_and_test_files/'+filename_sav, 'rb'))
        
        transformed_data = model.transform(count_data)

        transformed_data_uncategorized = model.transform(count_vectorizer.transform(summary_uncategorized_df['summary_text_processed']))

        if not os.path.exists('lda_topic_csv_files'):
            os.makedirs('lda_topic_csv_files')

        with open('lda_topic_csv_files/summary_category_new_category_'+str(iteration)+'.csv', 'w+', encoding = "utf8") as fn:
            fn.write('original_summary\toriginal_category\tnew_category\n')
            for i in range(len(summaries_with_outcome)):
                fn.write(summaries_with_outcome[i][0]+'\t'+summaries_with_outcome[i][1]+'\t'+'topic_'+str(np.argmax(transformed_data[i]))+'\n')
            for i in range(len(summaries_with_outcome_uncategorized)):
                fn.write(summaries_with_outcome_uncategorized[i][0]+'\t'+summaries_with_outcome_uncategorized[i][1]+'\t'+'topic_'+str(np.argmax(transformed_data_uncategorized[i]))+'\n')

        lines = [line.rstrip() for line in open('lda_topic_csv_files/summary_category_new_category_'+str(iteration)+'.csv', 'r', encoding = "utf8")]
        o_c_n_c_dict = {}
        first_line = True
        for line in lines:
            if first_line:
                first_line = False
                continue
            tup = line.split('\t')
            if (tup[1],tup[2]) in o_c_n_c_dict:
                o_c_n_c_dict[(tup[1],tup[2])] += 1
            else:
                o_c_n_c_dict[(tup[1],tup[2])] = 1

        
        with open('lda_topic_csv_files/summary_category_new_category_'+str(iteration)+'_aggregated.csv', 'w+', encoding = "utf8") as f:
            f.write('original_category,new_category,frequency\n')
            for k, v in o_c_n_c_dict.items():
                f.write(k[0]+','+k[1]+','+str(v)+'\n')


        topic_distribution = [np.argmax(x) for x in transformed_data]

        topic_distribution = topic_distribution+ [np.argmax(x) for x in transformed_data_uncategorized]

        frequency = [0]*20

        topics = [str(i) for i in range(20)]

        for a in topic_distribution:
            frequency[a] += 1

        f, ax = plt.subplots()

        plt.bar(topics, frequency)
        plt.title('Topic Distribution')
        plt.xlabel('Topic')
        plt.ylabel('Frequency')
        ax.set_xticks(range(20))
        ax.set_xticklabels(topics)

        fig = plt.gcf()

        if not os.path.exists('summaries_and_freq_graphs'):
            os.makedirs('summaries_and_freq_graphs')
        fig.savefig('summaries_and_freq_graphs/'+filename, dpi=fig.dpi)

        list_of_5_summaries_by_topic = [
            [],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]
        ]

        for i in range(len(summaries)):
            if len(list_of_5_summaries_by_topic[topic_distribution[i]])<=5:
                list_of_5_summaries_by_topic[topic_distribution[i]].append(summaries[i])

        for i in range(len(list_of_5_summaries_by_topic)):
            text_filename = 'summaries_and_freq_graphs/'+filename+'_'+str(i)+'.txt'
            with open(text_filename, 'w+') as f:
                for j in range(len(list_of_5_summaries_by_topic[i])):
                    f.write('Summary: '+list_of_5_summaries_by_topic[i][j]+'\n')

if __name__ == "__main__":
    main()