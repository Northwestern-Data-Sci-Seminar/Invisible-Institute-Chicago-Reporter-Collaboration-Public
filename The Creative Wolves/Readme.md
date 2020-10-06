Before You Continue
Please be aware that the following instructions are for running the code on Datagrip ONLY. 
Please make sure you have an active connection to cpdb database and select the corresponding schema. You can follow the instructions on how to setup Datagrip posted in Piazza. Once Datagrip is ready, either copy and paste the codes into the console and run or open the sql files mentioned below and run. 

**Question 1: What is the average number of complaints received by the top 4000 officers who received the most allegations? How does it compare to the average complaint count of all officers who have received at least one allegation?
-How to run the code: In SQL file ‘[cp1]q1.sql, there are two blocks of code under the Q1 section. Copy and paste each block into the console Datagrip or similar IDE, and make sure you loaded the correct schema before running each block.
-How to read results: The first block outputs the average number of complaints of top 4000 officers with the most complaints and the second block outputs the average number of complaints of all officers who have at least one complaint. Both output tables are single-column and single-cell. 
 
**Question 2: What is the average salary received by the top 4000 of officers who received the most allegations? How does it compare to the average salary of all police officers who have received at least one allegation? (Maximum salary will be used for standardization)
-How to run the code: In SQL file ‘[cp1]q2.sql, there are two blocks of code under the Q2 section. Copy and paste each block into the console Datagrip or similar IDE, and make sure you loaded the correct schema before running each block.
-How to read results: The first block outputs the average salary of top 4000 officers with the most complaints and the second block outputs the average salary of all officers who have at least one complaint. Both output tables are single-column and single-cell. 
 
**Question 3: Does the top 4000 of officers tend to receive awards? What is the average number of awards received by them?
-How to run the code: In SQL file ‘[cp1]q3.sql, copy and paste each block into the console Datagrip or similar IDE, and make sure you loaded the correct schema before running each block.
-How to read results: The table has only one column, which is the average number of awards received by all repeaters. 
 
**Question 4: Where are the majority of the top 4000 officers with most allegations deployed? Was there a change in the complaints received in the duration when their assigned region was changed?
-How to run the code:  In SQL file ‘[cp1]q4.sql, copy and paste each block into the console Datagrip or similar IDE, and make sure you loaded the correct schema before running each block.
-How to read results: The table has only one column, which is the region where most allegations happened amongst repeaters, which can be regarded as the region where repeaters were deployed the most. 
 
**Question 5: In how many different ways are repeaters related? Do they share the same unit/beat? Do their names occur often in complaint reports together?
-How to run the code: In SQL file ‘[cp1]q5p1.sql’ and ‘[cp1]q5p2.sql’, copy and paste each block into the console Datagrip or similar IDE, and make sure you loaded the correct schema before running each block.
-How to read results: 
  When you run ‘[cp1]q5p1.sql’ you get 2 columns beat_id and no.of allegations for that beat. You can see the maximum value of complaints per beat from repeaters and average by adding avg aggregator. 
  When you run ‘[cp1]q5p2.sql’ you get 2 columns which show complaint_id and no. of co-accused among repeaters for each complaint. We can see here that the maximum is 53 since they’re ordered by no. of co-accused.
