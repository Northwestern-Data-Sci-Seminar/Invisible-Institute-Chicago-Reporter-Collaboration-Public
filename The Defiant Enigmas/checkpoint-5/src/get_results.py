import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.manifold import TSNE
from sklearn.feature_extraction.text import TfidfVectorizer, CountVectorizer
from sklearn.decomposition import NMF, LatentDirichletAllocation
from sklearn.cluster import KMeans
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import f1_score

def results(X, y, list_of_summaries, categories, max_tree_depth):

    # Scaling
    X = StandardScaler().fit_transform(X)
    
    X_train = X[:1000,:]
    X_test = X[1000:,:]

    y_train = y[:1000]
    y_test = y[1000:]

    # Decision Tree
    #clf = DecisionTreeClassifier(random_state=100, max_depth=5)
    clf = RandomForestClassifier(random_state=100, max_depth=max_tree_depth)
    clf.fit(X_train, y_train)
    y_pred = clf.predict(X_train)
    print("Training")
    print("  Accuracy: {}".format(np.mean(y_pred == y_train)))
    print("  F1 Score: {}".format(f1_score(y_train, y_pred)))
    y_pred = clf.predict(X_test)
    print("Validation")
    print("  Accuracy: {}".format(np.mean(y_pred == y_test)))
    print("  F1 Score: {}".format(f1_score(y_test, y_pred)))

    ## PCA
    pca = PCA(n_components=2, svd_solver='full')
    principle_components = pca.fit_transform(X)
    pc_df_pce = pd.DataFrame(data = principle_components, columns = ['dim 1', 'dim 2'])

    ## TSNE
    tsne = TSNE(n_components=2, random_state=100)
    tsne_components = tsne.fit_transform(X)
    pc_df = pd.DataFrame(data = tsne_components, columns = ['dim 1', 'dim 2'])


    # NMF
    tfidf_vectorizer = TfidfVectorizer(max_df=0.95, min_df=2, stop_words='english')
    tfidf = tfidf_vectorizer.fit_transform(list_of_summaries)
    tfidf_feature_names = tfidf_vectorizer.get_feature_names()

    # LDA
    tf_vectorizer = CountVectorizer(max_df=0.95, min_df=2, stop_words='english')
    tf = tf_vectorizer.fit_transform(list_of_summaries)
    tf_feature_names = tf_vectorizer.get_feature_names()

    no_topics = 3

    # Run NMF
    nmf = NMF(n_components=no_topics, random_state=100, alpha=.1, l1_ratio=.5, init='nndsvd')
    nmf_summary_topics_dist = nmf.fit_transform(tfidf)
    nmf_summary_topics = np.argmax(nmf_summary_topics_dist, axis=1)

    # Run LDA
    lda = LatentDirichletAllocation(n_components=no_topics, max_iter=5, learning_method='online', learning_offset=50.,random_state=100)
    lda_summary_topics_dist = lda.fit_transform(tf)
    lda_summary_topics = np.argmax(lda_summary_topics_dist, axis=1)

    def display_topics(model, feature_names, no_top_words):
        topics = []
        return [" ".join([feature_names[i]
                            for i in topic.argsort()[:-no_top_words - 1:-1]])
                                for topic in model.components_]

    no_top_words = 10
    nmf_topics = display_topics(nmf, tfidf_feature_names, no_top_words)
    lda_topics = display_topics(lda, tf_feature_names, no_top_words)

    kmeans = KMeans(n_clusters=no_topics).fit(X)


    fig = plt.figure(figsize = (12,8))
    ax = fig.add_axes([0,0,1,1])

    classes = list(range(no_topics))
    #classes = ['Operation/Personnel Violations', 'Use Of Force', 'Illegal Search', 'Verbal Abuse', 'Conduct Unbecoming (Off-Duty)', 'Lockup Procedures']
    colors = ['r', 'g', 'b', 'y', 'm', 'c']
    for cla, color in zip(classes, colors):
        index_filter = nmf_summary_topics == cla
        #index_filter = lda_summary_topics == cla
        #index_filter = kmeans.labels_ == cla
        #index_filter = y == cla
        #index_filter = categories == cla
        ax.scatter(pc_df.loc[index_filter, 'dim 1'], pc_df.loc[index_filter, 'dim 2'], color=color)
    ax.legend(nmf_topics)
    #ax.legend(lda_topics)
    #ax.legend(["Topic 1", "Topic 2"])
    #ax.legend(["Not Sustained", "Sustained"])

    # Uncomment to show allegation category distribution
    #index_filter = np.isin(categories, classes, invert=True)
    #ax.scatter(pc_df.loc[index_filter, 'dim 1'], pc_df.loc[index_filter, 'dim 2'], color='gray')
    #ax.legend(classes + ['Other'])

    ax.grid()
    plt.show()
