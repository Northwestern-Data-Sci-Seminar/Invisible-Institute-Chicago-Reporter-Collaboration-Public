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



# Helper function
def plot_10_most_common_words(count_data, count_vectorizer):
    words = count_vectorizer.get_feature_names()
    total_counts = np.zeros(len(words))
    for t in count_data:
        total_counts+=t.toarray()[0]
    
    count_dict = (zip(words, total_counts))
    count_dict = sorted(count_dict, key=lambda x:x[1], reverse=True)[0:10]
    words = [w[0] for w in count_dict]
    counts = [w[1] for w in count_dict]
    x_pos = np.arange(len(words)) 
    
    plt.figure(2, figsize=(15, 15/1.6180))
    plt.subplot(title='10 most common words')
    sns.set_context("notebook", font_scale=1.25, rc={"lines.linewidth": 2.5})
    sns.barplot(x_pos, counts, palette='husl')
    plt.xticks(x_pos, words, rotation=90) 
    plt.xlabel('words')
    plt.ylabel('counts')
    plt.show()

def print_topics(model, count_vectorizer, n_top_words):
    words = count_vectorizer.get_feature_names()
    to_print = ''
    for topic_idx, topic in enumerate(model.components_):
        to_print += '\nTopic #%d:' % topic_idx
        to_print += " ".join(words[i] for i in topic.argsort()[:-n_top_words - 1: -1])
    return to_print


def main():
    warnings.simplefilter('ignore', DeprecationWarning)
    sns.set_style('whitegrid')

    #os.chdir('..')

    #make pd df from allegation summaries
    summary_file = open('data/raw/complaints.json', encoding = "utf8")
    summary_data = json.load(summary_file)
    summary_file.close()
    summaries = []

    en_core = spacy.load('en_core_web_lg')

    for dicts in summary_data:
        summaries.append(dicts["summary"])

    summary_df = pd.DataFrame(summaries, columns=['summary'])

    stopwords = set(['cook county','chicago','allegedly','po','ofcer','sergeant','ipra','detective','accused', 'officer', 'officers', 'reporting', 'party', 'alleged', 'alleges', 'complainant', 'victim', 'police', '-pron-', 'pron', '-PRON-', '[-PRON-]', 'allege', 'accuse', 'report'])

    print('Preprocessing starting')

    #remove punctuation
    summary_df['summary_text_processed1'] = summary_df['summary'].map(lambda x: re.sub('[,\.!?]()', '', x))

    #convert to lower
    summary_df['summary_text_processed2'] = summary_df['summary_text_processed1'].map(lambda x: x.lower())

    #lemmatize
    summary_df['summary_text_processed3'] = summary_df['summary_text_processed2'].map(lambda x: " ".join([y.lemma_ for y in en_core(x)]))

    #remove years
    summary_df['summary_text_processed4'] = summary_df['summary_text_processed3'].map(lambda x: re.sub('(19|20)[0-9][0-9]', '', x))

    #remove stopwords
    summary_df['summary_text_processed'] = summary_df['summary_text_processed4'].map(lambda x: " ".join([item for item in x.split() if item not in stopwords]))

    print('Preprocessing finished')

    # Initialise the count vectorizer with the English stop words
    count_vectorizer = CountVectorizer(stop_words='english')

    # Fit and transform the processed titles
    count_data = count_vectorizer.fit_transform(summary_df['summary_text_processed'])

    for iteration in range(10):
        number_topics = 20
        number_words = 12

        print('Training model '+str(iteration))

        lda = LDA(n_components=number_topics, max_iter=80)
        lda.fit(count_data)

        filename = 'lda_models_and_test_files/lda_model_iteration_'+str(iteration)+'_topics_'+str(number_topics)+'_words_'+str(number_words)

        filename_sav = filename+'.sav'

        filename_txt = filename+'.txt'

        if not os.path.exists('lda_models_and_test_files'):
            os.makedirs('lda_models_and_test_files')

        with open(filename_sav, 'wb') as f:
            pickle.dump(lda, f)

        with open(filename_txt, 'w+') as f:
            f.write('Topics found via LDA:')
            st = print_topics(lda, count_vectorizer, number_words)
            f.write(st)
            st = str(lda.transform(count_data[-10:]))
            f.write(st)

if __name__ == "__main__":
    print('Running...')
    main()