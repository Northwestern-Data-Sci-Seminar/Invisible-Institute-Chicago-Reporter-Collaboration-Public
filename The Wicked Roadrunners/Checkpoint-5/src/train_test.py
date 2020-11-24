import nltk
import pickle
nltk.download('punkt')
nltk.download("stopwords")
from nltk.corpus import stopwords
nltk.download("wordnet")
from nltk.stem import WordNetLemmatizer
from sklearn.feature_extraction.text import TfidfVectorizer
import sklearn.metrics as metrics
from sklearn.model_selection import cross_val_score
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import MultinomialNB
import matplotlib.pyplot as plt

# load in data set
df = pd.read_csv('verbal_abuse.csv')

# visualize class imbalance between verbal abuse presence
plt.title("Original Verbal Abuse Class Imbalance")
plt.bar(*zip(*df['verbal_abuse'].value_counts().items()))
labels = ['False','True']
plt.xticks([0,1], labels)
plt.xlabel('Verbal Abuse in Summaries ')
plt.ylabel('Frequency')
plt.show()


# resample to fix imbalance
class_0 = df[df['verbal_abuse'] == 0]
class_1 = df[df['verbal_abuse'] == 1]
class_count_0, class_count_1 = df['verbal_abuse'].value_counts()
class_1_over = class_1.sample(class_count_0, replace=True)
df = pd.concat([class_1_over, class_0], axis=0)

# visualize class imbalance between verbal abuse presence
plt.title("Fixed Verbal Abuse Class Imbalance")
plt.bar(*zip(*df['verbal_abuse'].value_counts().items()))
labels = ['False','True']
plt.xticks([0,1], labels)
plt.xlabel('Verbal Abuse in Summaries ')
plt.ylabel('Frequency')
plt.show()


texts = df['summary'].astype(str)
y = df['verbal_abuse']

# NOTE: we used this tutorial to help with creating our model
# https://www.datasciencelearner.com/text-classification-using-naive-bayes-in-python/


# Lematized words
def custom_tokenizer(s):
    lemmatizer = WordNetLemmatizer()
    tokens = nltk.word_tokenize(s)
    remove_stopwords = list(filter(lambda token: token not in stopwords.words("english"), tokens))
    lematize_words = [lemmatizer.lemmatize(word) for word in remove_stopwords]
    return lematize_words


vectorizer = TfidfVectorizer(tokenizer=custom_tokenizer)
tfidf = vectorizer.fit_transform(texts)

# split into training and test data set
x_train, x_test, y_train, y_test = train_test_split(tfidf, y, test_size=0.2, random_state=0)
# Model Building
clf = MultinomialNB()
clf.fit(x_train, y_train)
pred = clf.predict(x_test)
print("Confusion Matrix:\n", metrics.classification_report(y_test, pred), "\n")
print("Accuracy:\n", metrics.accuracy_score(y_test, pred))


# save the model to disk
filename = 'finalized_model.sav'
pickle.dump(clf, open(filename, 'wb'))

# load the model from disk
loaded_model = pickle.load(open(filename, 'rb'))

scores = cross_val_score(loaded_model, tfidf, y, cv=5, scoring='accuracy') #try using 'accuracy', 'precision', 'recall', and 'f1_macro' for the scoring parameter
print("CV scores = ", scores)


