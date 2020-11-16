## Checkpoint 3
For each of the "questions" below, their running method are also listed.

1. Using a decision tree, first we will preprocess features of officers in the three dimensions discussed above and group them into bins. Then we can utilize the tree to not only make predictions such as the number of complaints, allegations, sustained allegations, and use of force reports that officers will have in the following year, but also extract most important, defining features by extracting the topmost level of decision trees.

> TODO

2. Utilizing graph neural networks, and the attention mechanism from NLP literature, make a general predictor which can understand network structures of the web (made up of the three dimensions discussed above), by extracting the attention layer of the GNN we can acquire an importance weight vector of different dimensions of data. The GNN predictor will output the predicted number of officer complaints for the next year when given a complete history trajectory of that officer. The history trajectory includes officer/civilian allegation events, award events, etc.

> The default configuration requires a local running distance of cpdb on postgresql, however, you can change the credential dict in `GNN/train.py` to switch to your database.
> Type `python3 GNN/train.py -h` for help, normally you should run:
```
python3 GNN/train.py --patience 200 --min-year 2006 --max-year 2013
```


