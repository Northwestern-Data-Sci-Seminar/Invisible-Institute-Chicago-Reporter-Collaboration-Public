# Checkpoint 2: Data Visualization
## Hawkins Gay, Alex Leidner, Ramsey Wehbe <br />


## Theme:
   As members of the healthcare community our team would like to look into complaints and use of force in which injury was reported. Either alleged or sustained injury has the possibility to incite EMS or healthcare resource allocation for physical or mental treatment.  Interesting topics within this overarching theme include assessing differences in race, gender and neighborhood as it relates to injury prevalence.  This can be examined for officer injury as well as complainant; in particular, it would be interesting to explore these demographics and potentially elicit patterns of abuse that could prevent further injury. The severity and immediacy of EMS services could speak to restraint, or lack thereof, in the extreme, and even potentially to officer regret and responsibility in trying to immediately alleviate mistakes.
   
   As the course advances this topic would lend itself to traversing through the data parsing and visualization modules planned. While these are enumerated below, the ultimate task would be to try to parse through reports, using NLP, to add medical resource utilization to the known outcomes of TRR reports, either through parsing reports or inclusion of civil suits. This data, currently not included in attributes, would provide strong additional evidence to explore individual and societal impact.

## Running the code

This section of the code is to create Tableau visualizations. Created visualizations can be seen in the PDF or in the Tableau Workbook. <br />
These images were createad with psql 9.06.0201. <br />
Given connection issues to CPDB through tableau there are two versions of the workbook. <br />
.src\Checkpoint_2_Workbook_auto.twbx should contain 6/8 images and their table data offline, the final 2 images, Figure 2.1 and 2.2 you must log in with cpdb username and password to access. <br />
If this file does not allow for visualization please follow the steps ahead to insure that .src\Checkpoint_2_workbook.twb dependancies can be correctly linked. <br />

## Questions
 1)	[Use of force incidents by demographics (race, gender, age) and percentage that result in injury or lead to emergency medical attention](#Question-1) 
 2)	[Choropleth map to assess geographic distribution for proportion of use of force incidents that result in injury.](#Question-2)
 
## Question-1
Use of force incidents by demographics (race, gender, age) and percentage that result in injury or lead to emergency medical attention <br />
For ease of use, csv files have been provided to link to Tableau. Please open .src\Checkpoint_2_Workbook.twb. After opening the workbook you must enter the correct password for cpdb-student. Please refer to the canvas for this password <br />
Please link the Race and Race % Sheet with .CP2\Race.csv <br />
Please link the Age and Age % Sheet with .CP2\Result_63.csv <br />
Please link the Gender and Gender % Sheet with .CP2\Result_64.csv <br />

These csv files were created using the cpdb database and the following SQL queries, which can be found in .src\checkpoint_2.sql. These can be runned and saved as csv files to 
recreate those tables, or the csv files have been provided as described above. <br />

Data for figure 1.1 and 1.2. Save as Race.csv 

 	SELECT subject_race,
        	count(*) AS total_use_of_force_events,
        	count(CASE WHEN subject_injured = 'true' THEN 1 END) AS subject_injuries,
        	count(CASE WHEN subject_injured = 'true' THEN 1 END)*100/count(*) AS percent_subject_injuries,
        	count(CASE WHEN subject_alleged_injury = 'true' THEN 1 END) AS subject_alleged_injuries,
        	count(CASE WHEN subject_alleged_injury = 'true' AND subject_injured != 'true' THEN 1 END)*100/
        	count(CASE WHEN subject_alleged_injury = 'true' THEN 1 END) AS percent_subject_alleged_injuries_not_counted
  	FROM trr_trr
  	GROUP BY subject_race
  	ORDER BY total_use_of_force_events DESC;

Data for figure 1.3 and 1.4. Save as Result_63.csv 

  	SELECT CASE
          	WHEN subject_age BETWEEN 0 AND 18 THEN '0-18'
          	WHEN subject_age BETWEEN 18 AND 40 THEN '18-40'
          	WHEN subject_age BETWEEN 40 AND 65 THEN '40-65'
          	WHEN subject_age > 65 THEN '>65' END AS age_group,
        	subject_race,
        	count(*) AS total_use_of_force_events,
        	count(CASE WHEN subject_injured = 'true' THEN 1 END) AS subject_injuries,
        	count(CASE WHEN subject_injured = 'true' THEN 1 END)*100/count(*) AS percent_subject_injuries,
        	count(CASE WHEN subject_alleged_injury = 'true' THEN 1 END) AS subject_alleged_injuries
  	FROM trr_trr
  	GROUP BY age_group,subject_race
  	ORDER BY age_group;

Data for Figure 1.5 and 1.6. Save as Result_64.csv

  	SELECT subject_gender, subject_race,
        	count(*) AS total_use_of_force_events,
        	count(CASE WHEN subject_injured = 'true' THEN 1 END) AS subject_injuries,
        	count(CASE WHEN subject_injured = 'true' THEN 1 END)*100/count(*) AS percent_subject_injuries,
        	count(CASE WHEN subject_alleged_injury = 'true' THEN 1 END) AS subject_alleged_injuries,
        	count(CASE WHEN subject_alleged_injury = 'true' AND subject_injured != 'true' THEN 1 END)*100/
        	count(CASE WHEN subject_alleged_injury = 'true' THEN 1 END) AS percent_subject_alleged_injuries_not_counted
  	FROM trr_trr
  	GROUP BY subject_gender,subject_race
  	ORDER BY total_use_of_force_events DESC;
  
## Question-2
Question 2: Choropleth map to assess geographic distribution for proportion of use of force incidents that result in injury. <br />
For ease of use, csv files have been provided to link to Tableau. Please open .src\Checkpoint_2_Workbook.twb. After opening the workbook you must enter the correct password for cpdb-student. Please refer to the canvas for this password <br />
Please link the district and district % Sheet with .CP2\District_HCG.csv <br />

These csv files were created using the cpdb database and the following SQL queries, which can be found in .src\checkpoint_2.sql. These can be runned and saved as csv files to 
recreate those tables, or the csv files have been provided as described above. <br />

Figure 2.1 and 2.2 were created by linking beats to districts using the following source:
[https://news.wttw.com/sites/default/files/Map%20of%20Chicago%20Police%20Districts%20and%20Beats.pdf] <br />

Data for figure 2.1 and 2.2 <br />
Due to districts being combined on the map district 12 and 13 are combined.<br />
Districts 21 23 and 26-30 are not on the map and have not been included. <br />

  	SELECT CASE
          	WHEN beat BETWEEN 100 AND 199 THEN '1st'
          	WHEN beat BETWEEN 200 AND 299 THEN '2nd'
          	WHEN beat BETWEEN 300 AND 399 THEN '3rd'
         	WHEN beat BETWEEN 400 AND 499 THEN '4th'
         	WHEN beat BETWEEN 500 AND 599 THEN '5th'
         	WHEN beat BETWEEN 600 AND 699 THEN '6th'
          	WHEN beat BETWEEN 700 AND 799 THEN '7th'
          	WHEN beat BETWEEN 800 AND 899 THEN '8th'
          	WHEN beat BETWEEN 900 AND 999 THEN '9th'
          	WHEN beat BETWEEN 1000 AND 1099 THEN '10th'
          	WHEN beat BETWEEN 1100 AND 1199 THEN '11th'
          	WHEN beat BETWEEN 1200 AND 1399 THEN '12th'
          	WHEN beat BETWEEN 1400 AND 1499 THEN '14th'
          	WHEN beat BETWEEN 1500 AND 1599 THEN '15th'
          	WHEN beat BETWEEN 1600 AND 1699 THEN '16th'
          	WHEN beat BETWEEN 1700 AND 1799 THEN '17th'
          	WHEN beat BETWEEN 1800 AND 1899 THEN '18th'
          	WHEN beat BETWEEN 1900 AND 1999 THEN '19th'
          	WHEN beat BETWEEN 2000 AND 2099 THEN '20th'
          	WHEN beat BETWEEN 2200 AND 2299 THEN '22nd'
          	WHEN beat BETWEEN 2400 AND 2499 THEN '24th'
          	WHEN beat BETWEEN 2500 AND 2599 THEN '25th'
          	WHEN beat BETWEEN 3100 AND 3199 THEN '31th'
          	WHEN beat BETWEEN 1200 AND 1299 THEN '12th'
          	END AS district_name,
          	count(*) total_events,
	  	count(case when officer_injured = 'True' then 1 end) as officer_injured,
	  	count(case when officer_injured = 'True' then 1 end)*100/count(*) as percent_officer_injured,
	  	count(case when subject_injured = 'True' then 1 end) as subject_injured,
	  	count(case when subject_injured = 'True' then 1 end)*100/count(*) as percent_subject_injured
  	from trr_trr
  	group by district_name
  	order by officer_injured desc;



