#   **README**
**How to Run the queries**


The queries are provided in a single .sql file named **checkpoint1.sql** inside the **src** folder. The query for each of the questions is separated by a comment. To run a query for a particular question, just select the query and then click on the green run button in the top toolbar in DataGrip.


 **Proposal Questions**

1. **What is the average value of settlement money based on your race?**

    The query for the above question gives us a table which shows us two different columns. 

    **Average_Payments:** Defines the average money earned per case by a particular race.

    **Subject_Race:** Gives us the race for the particular row.

	**Count:** It shows the number of cases that were considered for each race while calculating the average payouts.
	
2. **What were the misconducts that won settlements? Which was the most common misconduct?**

    There are two tables for the particular question. The first table shows the categories and the frequency of each of the misconduct. Each column represents a different category of the misconduct that was reported in the lawsuits that won settlements. The row represents the frequency of those misconducts.

	The second table meanwhile shows us category of misconduct that the victims had most commonly appealed to in their allegations.

3. **With respect to allegations, does a particular combination of police race and victim race have a larger chance of being sustained?**

	To understand the impact of this particular query we have divided our findings in two tables to understand how many total allegations were made and how many of them were actually sustained.

	The query contains a commented line :

	    -- where data_officerallegation.final_finding = 'SU'

	Uncommenting this will give us the result for the sustained allegations out of the total allegations.

	The query for this question gives us a table that represents the different combinations of races that exist between a police officer and the complainant. The table is divided into 5 columns:

	**Police_race:** This represents the race of the police officer against which a particular allegation was filed.

	**Victim_race:** This represents the race of the victim. (Complainant)

	**alleg_count:** This represents the number of allegations by the victim race on the police race (if the aforementioned line is uncommented it gives the count of the sustained allegations).

	**officer_allegs:** This represents the total number of allegations on the particular police race. 

	**percent:** Gives us how much percent of the allegations does alleg_count constitute of the officer_allegs.



4. **Does the race of police officer investigating an allegation play a role in whether the allegation is sustained?**

    The table resultant from the query represents the different combinations of  races that exist between a police officer under investigation for an allegation and the investigation officer that led the investigation against the officer. Similar to the previous table you can uncomment the following line 

		-- where data_officerallegation.final_finding = 'SU'

	to get the number of allegations that were  and the count of the allegations that were sustained.

	The 3 columns in the table represents the following:

	**Police_race:** The race of the police officer
   
	**Investigator_race:** The race of the investigation officer
	
	**investigator_Count:** The count of the cases that were investigated by the investigator with a particular race to particular race of the police officer.

	**total_investigations:** Total investigations that the particular race underwent.

	**percent:** Gives us how much percentage of the allegations does the investigator of the particular race constitute of the total allegations that the race underwent. 
