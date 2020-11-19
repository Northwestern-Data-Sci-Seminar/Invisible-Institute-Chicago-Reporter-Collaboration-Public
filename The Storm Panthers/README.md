# Safe at home? Examining the impact of police-led home invasions in Chicago and predicting the effect of policy change involving “no-knock” warrants and officer-led illegal searches.

This project was undertaken for Jennie Rogers' Fall 2020 Data Science seminar. It is divided into five checkpoints based on that class structure.

## Background
On March 13, 2020, a Black woman named Breonna Taylor was fatally shot in her sleep by plainclothes white officers who entered her apartment as part of an investigation into drug dealing operations. In the aftermath of the killing of Breonna Taylor, renewed attention has been brought to the presence of “no-knock” warrants, or warrants that permit officers to enter a residence. “No-knock” warrants are legal in many states, including Illinois. Illinois also has a Stand-Your-Ground law, so the legal conflict that created the circumstances surrounding Breonna Taylor’s death also exists in Illinois. We investigate the impact of “no-knock” warrants, as well as home searches conducted without a warrant, in Chicago.

## Checkpoint 1: Relational Analytics

#### Questions Asked and Answers (at the time - queries are given which can be re-run with most recent data as long as the schema has not changed)
- How many officers who were involved in a “Search Of Premise Without Warrant” are still on the force today, and what proportion of all officers involved in these illegal searches do they constitute?
  - There are 25292 total officers involved in such a complaint and 52.93% of them remain active.
- Are there any officers who’ve been involved in more than one home invasion? What are their IDs and number of illegal searches? How many total repeaters are there?
  - 2569 officers have been involved in multiple home invasions. Take this with a grain of salt because supervisors are tagged in complaints, so may be more frequently implicated.
- How many instances of a “Search Of Premise Without Warrant” occurred at someone’s home (Apartment, Other Private Premise, Private Residence, or Residence)? Then, list these allegations and other relevant data (address, incident date, etc).
  - 2840 instances occurred at one of these private residences. This criterion is what we have used going forward in the rest of our project.
- What outcomes have resulted for victims from lawsuits involving a “Home Invasion”?

  | outcome | number\_of\_occurences | percent\_of\_total |
  | :--- | :--- | :--- |
  | Charged | 123 | 45.72 |
  | No Outcome Recorded | 118 | 43.87 |
  | Hospitalized | 42 | 15.61 |
  | Detained | 20 | 7.43 |
  | Killed | 6 | 2.23 |

- How many Wrong Address allegations have been made?
  - There were four allegations tagged Wrong Address in the settlement data.
- How many Wrong Address allegations led to settlements?
  - Based on matching incident dates, only one Wrong Address allegation led to a settlement in our settlement data. 
- Are officers involved in Wrong Address allegations linked to related settlements?
  - 18 officers have been involved in Wrong Address allegations that we could link to settlements. 
- What outcomes have resulted for officers named in “Search Of Premise Without Warrant” allegations?

  | officer\_outcome | number\_of\_occurences | percent\_of\_total |
  | :--- | :--- | :--- |
  | No Penalty | 24593 | 99.58 |
  | Temporary Suspension | 51 | 0.21 |
  | Reprimand | 37 | 0.15 |
  | Resigned or Removed | 11 | 0.04 |
  | Violation Noted | 5 | 0.02 |

#### Tools used:
- SQL
- DataGrip

## Checkpoint 2: Data Visualizations

#### Visualizations with explanations

- Word Frequency Wordcloud

This visualization presents the frequency of words within summaries of home invasion settlement cases (sourced from the Settling for Misconduct Dataset that is now available in cpdb). The bigger the word, the more often it appears in summaries. You can hover a word to view this frequency. In our custom SQL statement, we filtered for words that are greater than 3 characters long, transformed all words to lowercase, filtered to words that appeared 50 or more times, and finally, we removed the following words from the dataset: when, they, were, with, them, that, their, while. Below is the custom SQL query used to gather our data for this visualization:

    with lower_summaries AS (select LOWER(summary) as summary from lawsuit_lawsuit where 'Home invasion'=ANY(interactions)),
    words AS (select unnest(regexp_matches(summary, '(\w{4,})', 'g')) as summary_words from lower_summaries),
    word_counts as (select summary_words, count(summary_words) as count from words group by summary_words)
    select summary_words, count from word_counts where count >= 25
    AND summary_words not in ('when', 'they', 'were', 'with', 'them', 'that', 'their', 'while')

A preview of the visualization:
![viz1](https://github.com/Northwestern-Data-Sci-Seminar/Invisible-Institute-Chicago-Reporter-Collaboration-Public/blob/master/The%20Storm%20Panthers/checkpoint-2/images/wordcloud1screenshot.png?raw=true)

- "What victims were doing when..." Wordcloud

  This visualization presents what victims who received a settlement for a CPD home invasion were doing at the onset of the invasion. The larger the size of the text, the larger the settlement amount was. You can hover over each entry to view the total settlement amount. When browsing the Settling for Misconduct interface, we noticed that many of the summaries were written in the format, "\[victim\] was \[doing something\] when \[the police entered their home\]". Thus, we exploited this observation to extract substrings of the summaries that did follow that structure. We also filtered down to summaries that were between 2 than 100 characters (not inclusive) to clean out some substrings that were mistakenly grabbed. Below is the custom SQL query used to gather our data for this visualization:

      with eligible_summaries as (SELECT summary, total_settlement from lawsuit_lawsuit where 'Home invasion'=ANY(interactions) AND summary ILIKE '%was%when%'),
      segments as (select distinct substring(summary from 'was (.*?) when') as was_doing, total_settlement from eligible_summaries)
      select was_doing, cast(total_settlement as int) as amount, CONCAT('$', cast(total_settlement as int)) as tooltip from segments where length(was_doing) < 100 AND length(was_doing) > 2

  A preview of the visualization:
![viz2](https://github.com/Northwestern-Data-Sci-Seminar/Invisible-Institute-Chicago-Reporter-Collaboration-Public/blob/master/The%20Storm%20Panthers/checkpoint-2/images/wordcloud2screenshot.png?raw=true)

- Settlement Expenditure Dashboard

  This dashboard features three graphs:

   * CPD total settlement expenditures by year
   * CPD home invasion settlement expenditures by year
   * How much of CPD's yearly settlement expenditures are from home invasion cases?

   Because the `incidents` column stores arrays of the one or more incident types, the second and third graphs required a custom SQL query to extract only the home invasion cases.

   The custom SQL query for the second graph:

      select incident_date, total_settlement from lawsuit_lawsuit where 'Home invasion'=ANY(interactions)


   The custom SQL query was used for the final graph:

      with all_settlements as (select extract(year from incident_date) as year, sum(total_settlement) as total from lawsuit_lawsuit group by year),
      home_settlements as (select extract(year from incident_date) as year2, sum(total_settlement) as home from lawsuit_lawsuit where 'Home invasion'=ANY(interactions) group by year2)
      select cast(year as int), home, total, home/total*100 as percent_of_total from all_settlements inner join home_settlements on all_settlements.year=home_settlements.year2

  A preview of the visualization:
![viz3](https://github.com/Northwestern-Data-Sci-Seminar/Invisible-Institute-Chicago-Reporter-Collaboration-Public/blob/master/The%20Storm%20Panthers/checkpoint-2/images/viz3screenshot.png?raw=true)

#### Tools used:
- Tableau

## Checkpoint 3: Interactive Visualization and Data Exploration

#### Visualizations with explanations

- Map of Chicago Home Invasions

  [See visualization here](https://observablehq.com/@mandydavis/allegations-of-police-misconduct-in-chicago-with-an-emphas)
  
  This visualization used the results of query c3_q1 and c3_q1b. It is a map of Chicago that breaks the city down into community areas and presents the number of allegations that have occurred in each area, along with demographic data and points representing the location of allegations that appear to be police-led home invasions. 

  Observations: 

  Hovering over each area makes it very clear that the areas that are most affected by police misconduct are very highly populated by black residents. We can also see a cluster of home invasion points surrounding one of those most highly impacted areas, suggesting that home invasion misconducts may be associated with misconducts in general, which is to be expected. Another takeaway is that Chicago, in terms of police misconduct allegations, cannot be clearly separated into, for example, a "South Side" and a "North Side." People familiar with only these terms and their associations may have predicted a more smooth gradient on the map in terms of color. However, it is clear that there are pockets higher in allegation count on the West side of the city, the South side of the city, and other areas in between.

  Drawbacks:

  By looking at the map, we can see that there are two points that fall outside of the boundaries of Chicago. Theoretically, no point should exist in this database that does not belong within Chicago, but this visualization demonstrates that is not true. Based on looking at other points stored in the database, we also know that there are much more than just these two points that fall into that category. This faulty data made it very difficult to find a robust method for mapping all data completely and accurately. Another drawback is the limitations that come along with the constraint of needing to select one area type to map. For example, not all area types contain data regarding demographics, so since demographics were important to us in this visualization, we could not have mapped based on beats, for example. 

- Breakdown of Home Invasion Victims by Race and Gender

  [See visualization here](https://observablehq.com/@fobkid20/victim-gender-race-3)
  
  This visualization used the results of query c3_q2. It depicts the race and gender of victims of home invasion based on complaints tagged “Search Of Premise Without Warrant” in residences or private property. The visualization is togglable by race and gender.

  Observations: 

  One thing immediately clear from this data is that women are more likely to report being victim of this type of interaction, regardless of race. Another is that Black individuals are overrepresented in this population, while Asian/Pacific Islanders are underrepresented. 

  Drawbacks:

  There are several things not captured by this visualization. For one, the races provided in the data are mutually exclusive. However, in reality, individuals may identify as multiple races, say White and Hispanic. This is a flaw in the underlying data. Another limitation is the lack of inclusion of the demographic breakdown of Chicago, which itself contains key information necessary for understanding which home invasion populations are over or underrepresented relative to their prevalence in the community at large. This would tell us, for instance, that though Hispanics and Whites appear to be equally targeted based on the visualization, the White population is 16% larger than the Hispanic population as of the 2010 census, so the minority Hispanic population is actually overrepresented in home invasions. It would tell us more clearly the degree to which the Black population is overrepresented (70% of home invasion complaints vs. 33% of Chicago population) or the Asian/Pacific Islander population is underrepresented (0.68% of home invasion complaints vs. 5.5% of Chicago population).


- Breakdown of Officers Implicated in Home Invasions Over Time by Race, Gender, and Age

  [See visualization here](https://observablehq.com/@brendoneby/officers-involved-in-home-invasion-cases-per-1000-active-of)

  This visualization shows the incident rates of allegations of “search of premises without warrant” based on the demographics of the officers involved.  As there is an unequal distribution of officer demographics within the police force (white males make up the largest group), we chose to show incident rates per 1000 officers that meet the user-specified parameters.  For this question, we chose to focus on all premises searches that are either private residences or of unknown location type, as there is not enough data for private residences alone.

  This rate is found by dividing total incidents in each year (query c3_q3a.sql) by the total estimated officers on the force in the specified year (query c3_q3b.sql), then multiplied by 1000.  Before division, both lists are filtered as specified by the user.  We looked at gender, age group, and race as available filters.

  Observations: 
  1. By changing the demographic parameters we can see the incident rates over time for each demographic group.  These demographics showed the following trends:
      1. Male officers are more than twice as likely to be involved in these incidents than female officers.
      2. Officers in their 20s and 30s are far more likely to be involved in these incidents than officers 40 and above, again more than double the rates of higher age groups.  These rates go down in every subsequent age group.
      3. White and Hispanic officers are more likely to be involved in these incidents than other ethnicities.
      4. Combining the above observations, we can see that young white and hispanic males are by far the most likely officers to be involved with illegal searches, even after controlling for overall demographics within the police force. 

  2. All groups show a decrease in frequency of incidents over the last 20 years, especially after 2010. This may be due to increased public scrutiny of these kinds of practices, and easier access to documenting methods such as cell phones.

  3. Incidents overall increased until they peaked in the year 2000, then have decreased since then.  This is not uniform across demographics however.  In fact, it appears that white males (the largest demographic and therefore the most influential for overall trends) is the only demographic that shows this trend.  All other demographics show a general downward trend from the 90s through now.  This is curious, and it would be interesting to see what caused this unusual pattern among white men.

  4. Despite overall trends among non-white-male demographics being downward over time, most demographics had a spike in incidents in the year 2000 specifically, showing significantly higher rates than usual.  This would be interesting to look further into as well, perhaps there was a legal change that drove this trend.


#### Tools used:
- D3

## Checkpoint 4: Machine Learning

#### Questions Modeled and Results

- "How many home invasions and illegal searches can we expect in 2021 if there is no policy change?"

  - The predicted number of home invasion allegations in 2021 is 18.

- Coming Soon!

- "Can we predict which officers will be implicated in Home Invasion complaints?"
  - A LinearSVC model does better than chance with predicting which officers are involved in Home Invasion complaints, but not much better. This model (and indeed all models tested) does poorly with accurately identifying officers who were involved in Home Invasions, with more false positives than true positives. The model's accuracy is .608.

#### Tools used:
- Python
- scikit-learn

## Checkpoint 5: Natural Language Processing

- Coming soon!

#### Tools used:

- Coming soon!
