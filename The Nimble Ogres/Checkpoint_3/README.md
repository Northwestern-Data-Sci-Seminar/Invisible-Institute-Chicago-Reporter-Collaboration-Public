## Questions

* Is there any pattern between the race of the victim, and where the allegation was reported?
* How does the number of officers relate to the population of different areas of Chicago over the years?


## Instructions to run Observable Notebooks
Open the following links to see the executed code and the Choropleth maps.

For Question Q1:
https://observablehq.com/@madhavkh96/question-1/2

For Question Q2:
https://observablehq.com/@madhavkh96/question-1/4

## Instructions to run SQL Files

The Sql file is divided into different sections the first section is query which pulls the geographical data for the map of Chicago along with the demographics for each area.

The second section consists the queries required for running the observablehq notebook related to Question 1.

The third section consists 5 queries, 
 * The first query relates with getting the data for allegations against the police officers of a particular race in a particular area,
 * The rest of the queries basically relates to the shift duty data for different races each of these queries first create a temp table for a particular race and then inner joins to get the other relevant data. Here's the break up of the queries:
	 * Query 2: Shift data for white officers for each area
	 * Query 3: Shift data for black officers for each area.
	 * Query 4: Shift data for Hispanic officers for each area,
	 * Query 5: Shift data for Asian officers for each area.