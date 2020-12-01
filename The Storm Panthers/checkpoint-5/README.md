# Checkpoint 5: Natural Language Processing

## View the code and results
To view the code, visualizations, and results all in one place, check out our Google Colab notebook [here](https://colab.research.google.com/drive/1FxWZpqRLe9WKlM0H9wElr8CWDCJbg2XV?usp=sharing).

## Running the code on your local machine
If prefer to run our code outside of Google Colab, navigate to `The Storm Panthers/checkpoint-5/src/code`. Then, run `pip install -r requirements.txt`. Finally, run `pythonw narratives_tfidf.py`. There are three plots. You will have to exit out of one plot in order to view the next.

## Background

The goal for this checkpoint was to be able to classify allegation summaries as either “home disturbances” or “other.” We use the term “home disturbance” in order to broaden the category of “home invasions” that can be found in the Chicago Reporter settlements data and the category of “illegal search without a warrant” in the cpdb data. The reasoning for doing so comes down to our question of, “Are Chicagoans safe at home?” Warrant or not, invasion or not, we wanted to be able to identify incidents in which CPD cops were in a Chicagoan’s place of residence and caused some harm or disturbance. This keeps to our theme, as there have been some contested details about the warrant in Breonna Taylor’s case, but when it comes down to it, Breonna Taylor was not safe in her own home because of these police officers. We build an NLP model to identify similar cases by using TF-IDF as our approach.  

## Pre-processing
We started by pulling all narratives we could get from the CPDB database, and merged those results with the narratives provided separately by the Invisible Institute.

This yielded a collection of narratives and crids, but we still needed to cross reference this with the cpdb database to find which of these narratives matched with our target criteria, i.e. allegations labeled as “search of premise without warrant”, with a location of an apartment, residence, etc.  We used trifacta to join that data (flow attached), and to generate a list of 143 allegation summaries that are marked with our target criteria (which we will call “home invasions”).

However, to effectively train a model, we need to be certain about our home invasion matches and non-matches, and we suspected that some data may be misclassified, or incomplete, especially those that are not classified as matches.  So we pulled 180 non-matches from the processed list, and manually classified both those, and the 143 matches that were found.  We then reconnected this to the data in trifacta.  This resulted in 2 files (visible in src/data/): “labeled_data.csv” containing our training summaries and labels, and “unlabeled_data.csv” containing not-yet-classified summaries that we will apply our model to.

To paint a further picture of what was going on, we projected our top 50 most correlated features to 2 dimensions and came up with the following:

![features](https://github.com/Northwestern-Data-Sci-Seminar/Invisible-Institute-Chicago-Reporter-Collaboration-Public/blob/master/The%20Storm%20Panthers/checkpoint-5/images/features.png?raw=true)

## The model 
See [narratives_tfidf.ipynb](https://colab.research.google.com/drive/1FxWZpqRLe9WKlM0H9wElr8CWDCJbg2XV?usp=sharing).
We imported our labeled and unlabeled data, and used TF-IDF to generate features for classification.  We used monograms, bigrams, and trigrams as features, and used the standard english stop-words set.

We then tested 3 different classifiers, Random Forests, Multinomial NB, and Logistic Regression, using five-fold cross-validation.  We selected the highest performing model based on its average performance across the five folds, and used that as our classification model for the full dataset. The best-performing model was Multinomial Naive Bayes.

## Results
After our TF-IDF step, here are what we found to be the most-correlated monograms, bigrams, and trigrams for this labeled data:
Most correlated unigrams:
   . home
   . permission
   . residence
   . warrant
   . entered
Most correlated bigrams:
   . residence justification
   . officers entered
   . entered searched
   . searched residence
   . warrant permission
Most correlated trigrams:
   . officers entered home
   . entered home warrant
   . home warrant permission
   . searched residence justification
   . entered searched residence

Testing our model using our labeled data resulted in impressive performance despite the relatively small size of the training dataset. A Multinomial Naive Bayesian model performed the best at nearly 93% accuracy. Below are the full accuracy results for the three models we tested:
| Model | Accuracy|
|---|---|
| LogisticRegression | 0.841394 |
| MultinomialNB | 0.928558 |
| RandomForestClassifier | 0.776298 |


We created a confusion matrix to investigate if the inaccurate predictions tended to be false positives versus false negatives.


![confusion](https://github.com/Northwestern-Data-Sci-Seminar/Invisible-Institute-Chicago-Reporter-Collaboration-Public/blob/master/The%20Storm%20Panthers/checkpoint-5/images/confusion_matrix.png?raw=true)


Because the MultinomialNB’s accuracy was so high, only six summaries were misclassified from our testing set of 65 summaries. We further explored what those misclassifications were exactly:

### Summaries classified as “other” when the actual label was “home_invasion”

`On November 22, 2008, a complaint was registered with the Independent Police Review Authority (IPRA), regarding an incident occurring in the 6th District, on November 21, 2008. It was alleged that an off-duty Chicago Police Department (CPD) officer struck the complainant during a domestic altercation; damaged the complainants cell phone by smashing it to prevent her from calling the police; and damaged the bathroom door by punching it with his fist. Based on statements from the accused officer, reports, audio recordings, and photographs, IPRA recommended to SUSTAIN the allegations that the accused struck the complainant during a domestic altercation; and smashed the complainants cell phone to prevent her from calling the police. Further, IPRA recommended a finding of NOT SUSTAINED for the allegation that the accused damaged the bathroom door by punching it with his fist. IPRA recommended a three (3) day suspension for the accused officer.`

`THE REPORTING PARTY ALLEGES THAT THE ACCUSED OFFICER HAS BEEN LYING IN ORDER TO OBTAIN SEARCH WARRANTS. HE/SHE ALLEGES THAT THE ACCUSED OFFICER TAKES DRUG ADDICTS BEFORE JUDGES WITH FABRICATED TESTIMONY TO OBTAIN SEARCH WARRANTS THAT WERE NOT BASED ON, PROBALE CAUSE. HE/SHE FURTHER ALLEGES THAT DURING SEVERAL ARREST AND SEARCH WARRANTS, MONEY AND. JEWELRY HAVE BEEN STOLEN FROM THE CITIZEN'S RESIDENCES. THE REPORTING PARTY ALLEGES THAT THE ACCUSED OFFICER HAS BEEN LYING IN ORDER TO OBTAIN SEARCH WARRANTS. HE/SHE ALLEGES THAT THE ACCUSED OFFICER TAKES DRUG ADDICTS BEFORE JUDGES WITH FABRICATED TESTIMONY TO OBTAIN SEARCH WARRANTS THAT WERE NOT BASED ON, PROBALE CAUSE. HE/SHE FURTHER ALLEGES THAT DURING SEVERAL ARREST AND SEARCH WARRANTS, MONEY AND. JEWELRY HAVE BEEN STOLEN FROM THE CITIZEN'S RESIDENCES.`

`On February 4, 2009, a complaint was registered with the Independent Police Review Authority (IPRA), regarding an incident that occurred in the 2nd District on February 4, 2009 involving one on-duty Chicago Police Department (CPD) Sergeant (Sergeant A) and seven on-duty CPD Officers (Officers B through H). It was alleged that Sergeant A conducted an improper search; used improper force against Victim A; used improper force against Victim B; used improper force against Victim C; used improper force against Victim D; used improper force against Victim E; directed profanities at Victim A; directed profanities at Victim D; unnecessarily displayed a weapon; threatened to arrest Victim A without basis; engaged in improper verbal action against Victim A; submitted a false report; made a false statement to IPRA; disobeyed two Department Special Orders regarding searching premises; and that his overall actions were contrary to the stated policy, goals, rules, regulations, orders and directi...`

`The reporting party alleged that the accused officer detained the victim and entered their house without justification. The reporting party further alleged that, when she told the accused officer that she was going to file a complaint on him, he told her to ""shut the fuck up.”`

                                                                                                                                                                                    
### Summaries classified as “home_invasion” when the actual label was “other”
`The reporting party stated that the accused entered her place of business and arrested an unknown male/black for selling illegal dvds. The renortina partv alleges that the victim, mmented on the arrest, accused grabbed the ba car seat which causeu i wian uin i @ble. The     reporting party further alleges that the accused failed to give his name and star number upon request.`

`justification`            

## Applying the classifier
We took this model, and applied it to the full unlabeled dataset.  This came up with 495 summaries that the model labeled as “home invasions”, which was 8.3% of the 5935 unlabeled summaries.

To gauge the accuracy of this classification, we took 150 randomly selected summaries from that result set, and manually classified them (output_accuracy.csv).  On manual inspection we labeled 39 of those summaries as “Home Invasions”, which gives us a somewhat disappointing accuracy of 26%.  

## Shortcomings and Future work
The accuracy of our final model was pretty low when classifying new data, and very high when working off of the validation-split testing set, so we are likely seeing the results of our small amount of training data (and potential overfitting).

It would be very interesting to run this same analysis over a larger training set, and see if we can achieve higher accuracy.  One place to start would be to use our manually classified output set as additional training data, and re-run the model with that.

Another possibility would be to include a third (or fourth) category that encompasses many of our False Positives, but this would require a significant amount of manual effort in re-classifying new categories.

