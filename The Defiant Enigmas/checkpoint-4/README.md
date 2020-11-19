## Checkpoint 4
We are using two methods in checkpoint 4. The first method focuses on learning manually segmented structured data, while the second method focuses on learning semi-structured raw data with topology, we hope that by combining these two methods, we can gain more insights of data from multiple views

Begin by installing PyTorch by running `pip install torch==1.7.0+cpu -f https://download.pytorch.org/whl/torch_stable.html`.
Then, before running either of the models from their respective root directory, run `pip install -r requirements.txt`.

1. Using a decision tree, first we will preprocess features of officers in the three dimensions discussed above and group them into bins. Then we can utilize the tree to not only make predictions such as the number of complaints, allegations, sustained allegations, and use of force reports that officers will have in the following year, but also extract most important, defining features by extracting the topmost level of decision trees.

> To run the model and show the resulting decision tree, just execute the cp4.py file:
> ```
> python3 cp4.py
> ```

2. Utilizing graph neural networks, and the attention mechanism from NLP literature, make a general predictor which can understand network structures of the web (made up of the three dimensions discussed above), by extracting the attention layer of the GNN we can acquire an importance weight vector of different dimensions of data. The GNN predictor will output the predicted number of officer complaints for the next year when given a complete history trajectory of that officer. The history trajectory includes officer/civilian allegation events, award events, etc.

> The default configuration requires a local running distance of cpdb on postgresql, however, you can change the credential dict in `GNN/train.py` to switch to your database. And remember to `cd src/GNN` first.
> Type `python3 train.py -h` for help, normally you should run:
> ```
> python3 train.py --patience 200 --min-year 2006 --max-year 2013
> ```
> A tighter year range has better performance and uses less GPU memory.

