import pandas as pd
import sys
import string

from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize 
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer 

class SentimentData:

	def __init__(self, group):
		self.group = group
		self.sentence_count = 0
		self.total_positive_rate = 0
		self.total_negative_rate = 0
		self.total_compound_rate = 0
		self.total_negative_count = 0
		self.total_positive_count = 0
		self.total_neutral_count = 0


	def process_sentiment_result(self, result_dict):
		self.sentence_count += 1 
		self.total_positive_rate += result_dict['pos']
		self.total_negative_rate += result_dict['neg']
		self.total_compound_rate += result_dict['compound']
		if result_dict['compound'] >= 0.05:
			self.total_positive_count += 1
		elif result_dict['compound'] <= -0.05:
			self.total_negative_count += 1
		else:
			self.total_neutral_count += 1


	def get_results(self):
		print(f'\n \t ------{self.group} Results------')
		print(f'Total of {self.sentence_count} sentences', end ='\n')
		
		print(f'Positive Sentences {self.total_positive_count} ({round(self.total_positive_count / self.sentence_count * 100, 2)}%)')
		print(f'Negative Sentence {self.total_negative_count} ({round(self.total_negative_count / self.sentence_count * 100, 2)}%)')
		print(f'Neutral {self.total_neutral_count}')

		print(f'With Avg. Sentence Positive Score of {round(self.total_positive_rate * 100 / self.sentence_count, 2)}', end ='\n')
		print(f'With Avg. Sentence Negative Score of {round(self.total_negative_rate * 100 / self.sentence_count, 2)}', end ='\n')


class TextData:

	def __init__(self, dataframe, group="Repeaters"):
		self.raw_dataframe = dataframe
		self.mod_dataframe = None
		self.group = group
		self.analyzer = SentimentIntensityAnalyzer()
		self.stop_words = set(stopwords.words('english') + list(string.punctuation))
		self.sentimen_result = None
		self.sentiment_score = 0


	def update_stop_words(self, custom_stop_words=None) -> None:
		self.stopwords.add(custom_stop_words)


	def get_sentence_sentiment(self, sentence: str):
		analyzer = self.analyzer
		sentiment_result = analyzer.polarity_scores(sentence) 
		return sentiment_result


	def clean_sentence(self) -> None:
		self.mod_dataframe = self.raw_dataframe['summary'].apply(self._filter_sentence)


	def _filter_sentence(self, sentence) -> str:
		words = word_tokenize(sentence)
		filtered_sentence =  []
		for w in words:
			if w not in self.stop_words:
				filtered_sentence.append(w)

		result_sentence = " "
		return result_sentence.join([str(token) for token in filtered_sentence])



def process_data(file_path, group):
	summaryDF = pd.read_excel(file_path)

	text_data = TextData(dataframe = summaryDF, group = group)
	print("Cleaning Data...")
	text_data.clean_sentence()
	
	sentiment_data = SentimentData(group = group)
	print("Analyzing Sentiment...")

	for sentence in text_data.mod_dataframe:
		sentiment_result = text_data.get_sentence_sentiment(sentence=sentence)
		sentiment_data.process_sentiment_result(result_dict=sentiment_result)

	sentiment_data.get_results()


if __name__ == "__main__" : 

	process_data("repeater_summary.xlsx", group="Repeater")
	process_data("offender_summary.xlsx", group="Offender")
  
  	

