# Checkpoint 3: Hawkins Gay, Alex Leidner, Ramsey Wehbe <br />

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

This code consists of one sql file, cp4.sql in src used to generate our csv file. In addition there are 2 jupyter notebooks with our python codes. Please make sure the pointer to this csv file is correct before trying to run the code. We have included an os agnostic pointer that should work but please verify this can import data before trying to run. <br />

The cp4.csv file is in the notebooks/csv folder. In the notebooks folder, The jupyter notebooks are saved in a state where our models are observable however if you follow the index at the top of each jupyter notebook you will be able to rerun the analysis step by step to train, validate and test our models. We determined the optimal model parameters using gridsearch in question_2.ipynb, however this code has been commented out as it can take over an hour to run on a standard consumer cpu (this was run on a server with 4 CPUs with a total of 48 cores).

## Dependencies
Python == 3.7
Jupyter Notebook

Please install requirements.txt.
The environemnt dependencies are:
pandas
numpy
sklearn
matplotlib.pylpot

## Questions
 1)	[Predict police encounters (based on citizen and police demographics, alleged crime, neighborhood) where use of force incidents are likely to result in injury.](#Question-1)<br /> 
 2)	[Predict police encounters more likely to result in lethal uses of force vs. less-than-lethal uses of force.](#Question-2)
 
## Question-1
Predict police encounters (based on citizen and police demographics, alleged crime, neighborhood) where use of force incidents are likely to result in injury. <br />
The csv file for this code is created by running cp4.sql and saving the resulting table.
This question consists of 3 models. The best model Random Forest results can be seen at the end of the notebook.
The code for this file is contained in a notebook, question_1.ipynb. 


## Question-2
Predict police encounters more likely to result in lethal uses of force vs. less-than-lethal uses of force.<br />
The csv file for this code is created by running cp4.sql and saving the resulting table.
The code for this file is contained in a notebook, question_1.ipynb. This file starts by cleaning the data then produces a random forest with optimal hyperparameters using grid search with 5-fold cross validation.


