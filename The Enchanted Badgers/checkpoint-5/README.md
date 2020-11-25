# Checkpoint 5: Natural Language Processing

For this checkpoint, we sought to answer the following question.

### Question 1: Can we train a transformer language model (e.g. BERT) on a dataset of complaints with assigned categories (the input being the report narrative, and the label being the category) and use this trained model to predict the categories of complaints which are currently not categorized, or categorized as “unknown”?

To answer this question, we built a two different models: a bag of embeddings classifier and BERT classifier. The code and instructions for building and running them are included in `src/complaint_classification`.
