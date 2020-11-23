import nltk
import pickle
nltk.download('punkt')
nltk.download("stopwords")
from nltk.corpus import stopwords
nltk.download("wordnet")
from nltk.stem import WordNetLemmatizer
from sklearn.feature_extraction.text import TfidfVectorizer
import sklearn.metrics as metrics
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import MultinomialNB

# load in data set
data = pd.read_csv('verbal_abuse.csv')
texts = data['summary'].astype(str)
y = data['verbal_abuse']

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
print("Confusion Matrix:\n", metrics.confusion_matrix(y_test, pred), "\n")
print("Accuracy:\n", metrics.accuracy_score(y_test, pred))


# save the model to disk
filename = 'finalized_model.sav'
pickle.dump(clf, open(filename, 'wb'))

# load the model from disk
loaded_model = pickle.load(open(filename, 'rb'))
result = loaded_model.score(x_test, y_test)
print(result)

