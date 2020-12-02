# Checkpoint 5: Hawkins Gay, Alex Leidner, Ramsey Wehbe <br />

## Theme:
   As members of the healthcare community our team would like to look into complaints and use of force in which injury was reported. Either alleged or sustained injury has
   the possibility to incite EMS or healthcare resource allocation for physical or mental treatment.  Interesting topics within this overarching theme
   include assessing differences in race, gender and neighborhood as it relates to injury prevalence.  This can be examined for officer injury as well
   as complainant; in particular, it would be interesting to explore these demographics and potentially elicit patterns of abuse that could prevent
   further injury. The severity and immediacy of EMS services could speak to restraint, or lack thereof, in the extreme, and even potentially to officer
   regret and responsibility in trying to immediately alleviate mistakes.

   As the course advances this topic would lend itself to traversing through the data parsing and visualization modules planned. While these are enumerated below,
   the ultimate task would be to try to parse through reports, using NLP, to add medical resource utilization to the known outcomes of TRR reports, either through
   parsing reports or inclusion of civil suits. This data, currently not included in attributes, would provide strong additional evidence to explore individual and
   societal impact.

##Running the code

This code consists of one sql file, cp5.sql in src used to generate our csv file. In addition there are 2 jupyter notebooks with our python codes.
Please make sure the pointer to this csv file (path or csv_file) is correct before trying to run the code. We have included an os agnostic pointer
that should work but please verify this can import data before trying to run. <br />

The summary2.csv file is in the notebooks/csv folder. In the notebooks folder, The jupyter notebooks are saved in a state where our models are observable
however if you follow the index at the top of each jupyter notebook you will be able to rerun the analysis step by step to train, test print predictive
analytics for our models.

Please note: jupyter notebook unsupervised_NLP has computationally complex and was run on an external GPU.

## Dependencies
Python == 3.7
Jupyter Notebook

Please install requirements.txt.
The environemnt dependencies are:
pandas
numpy
sklearn
keras
re
gensim
tensorflow
spacy

## Questions
 1)	[Use NLP from the narratives within the CPDB to identify encounters that result in emergency medical care and if possible mode and outcome of that care – EMS (ambulance), hospital admission, emergency room.](#Question-1)<br />

## Question-1
Use NLP from the narratives within the CPDB to identify encounters that result in emergency medical care and if possible mode and outcome of
that care – EMS (ambulance), hospital admission, emergency room.


