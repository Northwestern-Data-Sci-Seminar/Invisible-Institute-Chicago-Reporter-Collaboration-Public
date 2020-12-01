# **Officer-complainant-community demographic correlations for complaint prediction**

*The Powerful Turtles*

*Team member: Jiangnan Fu, Yunan Wu, Ziyin Huang*

**Theme**

Recently, incidences of police abuse of authority led to several breaking news, and many
movements against police misconduct took place around the country. In most of the well-known
cases, the victims of police power abuse are underrepresented minorities, while the police officers
involved are white males. However, more detailed analyses on the officers’ and victims’
demographics are necessary to draw statistically significant correlations that can guide actionable
policy changes to reduce or prevent future police misconduct. Citizens Police Data Project
provides a data set of police complaint reports that can represent the overall population rather
than the individual cases from the news. In this project, with the help of this data set and various
data science tools, we would like to study how the demographics comparison between the
complainants and the respective police officers they reported correlate to the number of
complaints. With such a relationship, we can predict a police officer’s likelihood to be reported for
misconduct given the police-citizen demographic pairing.

**[Checkpoint-1: Relational Analytics Questions:](https://github.com/Northwestern-Data-Sci-Seminar/Invisible-Institute-Chicago-Reporter-Collaboration-Public/tree/master/The%20Powerful%20Turtles/checkpoint-1)**

1. What is the race distribution among the officers? 

2. What is the majority race in the community of which the officer with most complaints? 

3. What is the race distribution among the complainant? 

4. What percentage of officers have the same race with the majority race of their responsible community? 

5. What percentage of officers have the same race with the filer of their complaints? 

6. What percentage of filers of complaints have the same race with the majority race of their community? 

Needs to be added on. 



**[Checkpoint-2: Relational Analytics Questions:](https://github.com/Northwestern-Data-Sci-Seminar/Invisible-Institute-Chicago-Reporter-Collaboration-Public/tree/master/The%20Powerful%20Turtles/checkpoint-2)**

**Theme**

In this project, we would like to study how the demographics comparison between the complainants and the respective police officers reported correlating to the number of complaints. In this checkpoint, we perform data visualization of race distributions among the officers and the complainants using Tableau. The results from this checkpoint provide the foundation for the interactive data visualization tasks in the next checkpoint, where the cross-correlation between the officer race and complainant race with respect to the community race composition. Together, these visualizations will provide guidance for future checkpoints.


**Relational Visualization Questions:**

1. A pie chart showing the race distribution among the officers and the allegation counts within each race distribution.


2. A bar chart showing the race distribution among the complainant



**1. A pie chart showing the race distribution among the officers and the allegation counts within each race distribution.**

  Please open Tableau and use folder src/Q1.twb to show the visualization.




**2. A bar chart showing the race distribution among the complainant**

  Please open Tableau and use folder src/Q2.twb to show the visualization.

**[Checkpoint-3: Relational Analytics Questions:](https://github.com/Northwestern-Data-Sci-Seminar/Invisible-Institute-Chicago-Reporter-Collaboration-Public/tree/master/The%20Powerful%20Turtles/checkpoint-3)**

**Theme**

In this project, we would like to study how the demographics comparison between the complainants and the respective police officers reported correlating to the number of complaints. In this checkpoint, we perform interactive data visualization of race matching correlation between officers and complainants relative to the community race distribution. The results reveal uneven race distribution of officers compared to their corresponding community, and the race difference between officer and complainant in their corresponding community may contribute to higher numbers of complaints. The results from this checkpoint provide us some insights for selecting parameters for the machine learning checkpoint.

**Relational Analytics Questions:**

1. Stacked-to-Grouped Bars showing the relationship between officer race and the community population race. 

2. A scatter plot matrix showing the relationship between officer race percentage within community vs. complaint filer race percentage within the community. 


**1. Stacked-to-Grouped Bars showing the relationship between officer race and the community population race.**

    Please go to folder src/observable_link.txt or paste the link below:

https://observablehq.com/@yunanwu/stacked-to-grouped-bars.


**2. A scatter plot matrix showing the relationship between officer race percentage within community vs. complaint filer race percentage within the community.**

    Please go to folder src/observable_link.txt or paste the link below:

https://observablehq.com/d/a210438ec4686c6e. 


More details are shown in findings.pdf.

**[Checkpoint-4: Relational Analytics Questions:](https://github.com/Northwestern-Data-Sci-Seminar/Invisible-Institute-Chicago-Reporter-Collaboration-Public/tree/master/The%20Powerful%20Turtles/checkpoint-4)**

**Theme**

In this project, we would like to study how the demographics comparison between the complainants and the respective police officers reported correlating to the number of complaints. In this checkpoint, we break down the analysis from two different perspectives. The first part is to predict the number of complaints about each police officer based on the available police information. In the second part, we analyze the correlation between police demographics and complaint demographics to predict how such a correlation affects whether complaints take place.

**Relational Analytics Questions:**

1. Regression analysis to predict the number of complaints based on police information.

2. Predict the demographic difference interval between the officer and the complainant with the community that the two groups can live with each other with minimal complaints.


**1. Regression analysis to predict the number of complaints based on police information.**

    Please go to folder src/Checkpoint_4_Q1.ipynb or use the shared Colab link below:

https://colab.research.google.com/drive/1W-CW69jNw6j5Jm2hbW3H1UagJwPfaWM4?usp=sharing

**2. Predict the demographic difference interval between the officer and the complainant with the community that the two groups can live with each other with minimal complaints**

    Please go to folder src/Checkpoint_4_Q2.ipynb or use the shared Colab link below:

https://colab.research.google.com/drive/1zQyuDwcFXEiZ2HKkPA3S1eWnSTPecCwX?usp=sharing 


More details are shown in findings.pdf.



**[Checkpoint-5: Natural Language Learning:](https://github.com/Northwestern-Data-Sci-Seminar/Invisible-Institute-Chicago-Reporter-Collaboration-Public/tree/master/The%20Powerful%20Turtles/checkpoint-5)**

*Team member: Jiangnan Fu, Yunan Wu, Ziyin Huang*

**Theme**

In this checkpoint, we would like to study how the most common tokenized words for complainants against officers are different among different racial groups. 

**Relational Analytics Questions:**

1. Extract common tokenized words for complaints against officers in each race based on the narrative text data, and use these words to analyze hints on potential police misconducts.

**1. Extract common tokenized words for complaints against officers in each race based on the narrative text data, and use these words to analyze hints on potential police misconducts.**

    Please go to folder src/Checkpoint_5.ipynb or use the shared Colab link below:

https://colab.research.google.com/drive/1OIMYhKKK9KrWALy0hqx8et-Obk4SfKdM?usp=sharing
