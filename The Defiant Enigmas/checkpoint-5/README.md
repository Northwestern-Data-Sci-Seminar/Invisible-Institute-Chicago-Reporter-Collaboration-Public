## Checkpoint 5

### Research Question
For our Natural Language Processing task, we propose to employ a neural model to
obtain embeddings of allegation summaries, and then use these latent
representations to improve predictions of officer complaint rate or whether a
complaint will be sustained. Additionally, we can use these embeddings to do
clustering or topic modelling analysis to identify groups of complaints and
their common characteristics (e.g. if complaints within similar clusters emerge
from similar precincts, similar officers, etc.)

### Running the Code
TInstall all necessary packages by navigating to the checkpoint-5/src directory
from a terminal window and running
```
pip install -r requirements
```
and then, to download the spacy model, run
```
python -m spacy download en_core_web_lg
```
When installation of both of the above is complete, run the source code using
```
python main.py
```
Running this will show the scatterplots of t-SNE dimensionally reduced summary
embeddings, colored according to summary topic, found using non-negative matrix
factorization. Scatterplots in order are:
* 18-feature complaint tuples from database (no summary information)
* 300-feature complaint summary embeddings
* 318-feature tuples comprising the concatenation of the prior two tuples
Each figure may need to be closed before program execution continues.

