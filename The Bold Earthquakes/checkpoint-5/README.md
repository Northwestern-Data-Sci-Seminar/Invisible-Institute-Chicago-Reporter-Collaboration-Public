# Checkpoint 5: Natural Language Processing

For our NLP checkpoint we looked at the following question:

For complaint report narratives, is the text predictive of the complaint category?

For checkpoint 5, we struggled to come up with an NLP task that fit with our theme. Given the narratives dataset, we decided to look into the categorization of complaint report narratives. In seeing if we can predict the category of a complaint report narrative given the narrative’s text, we hope to gain some insight into the quality of the categorization.

We split the data into 2 datasets:
- Intakes
- Allegations

Directories:
* `src` contains the SQL scripts to obtain the csv data and the notebook
    * Script: `checkpoint_5_data.sql`
    * Notebook : `checkpoint_5_fasttext.ipynb`
* `data` there is no directory for data. The csv files can be found at urls:
	* narratives csv data: https://raw.githubusercontent.com/invinst/documentAnalysis/master/data/input/narratives.csv
	* crid map csv data: https://gist.githubusercontent.com/simon-benigeri/42b708386d460a52d99c82a5cf891770/raw/d226a962b9978cacb3e9bde3aa16bdc12bb9a685/crid_categories.csv
* `findings.pdf` contains our report
