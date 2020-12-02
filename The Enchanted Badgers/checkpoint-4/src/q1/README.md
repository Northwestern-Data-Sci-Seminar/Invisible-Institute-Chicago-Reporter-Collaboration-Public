## Setup

### Instructions to Reproduce LDA Topic Models
All LDA topic models have already been generated, but this sections contains directions on how to reproduce, if you would like to do so. Note that LDA is a nondeterministic process and the same set of topics are not guaranteed to be created during successive runs.

1. Run “pip install -r requirements_lda.txt”
2. Run “python -m spacy download en_core_web_lg”
3. Run “python lda.py”. This file preprocesses the narrative summaries and feeds it into Scikit-Learn’s LDA. We train 10 different LDA models, each with 20 topics described by 12 words each. 
    1. “lda.py” outputs a new directory “lda_models_and_test_files” which contains the models and the words that define the topics for each model