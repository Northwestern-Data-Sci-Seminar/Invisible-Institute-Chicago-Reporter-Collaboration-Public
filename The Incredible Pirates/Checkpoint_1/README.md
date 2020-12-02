# Checkpoint 1: Hawkins Gay, Alex Leidner, Ramsey Wehbe


## Theme:
   As members of the healthcare community our team would like to look into complaints and use of force in which injury was reported. Either alleged or sustained injury has the possibility to incite EMS or healthcare resource allocation for physical or mental treatment.  Interesting topics within this overarching theme include assessing differences in race, gender and neighborhood as it relates to injury prevalence.  This can be examined for officer injury as well as complainant; in particular, it would be interesting to explore these demographics and potentially elicit patterns of abuse that could prevent further injury. The severity and immediacy of EMS services could speak to restraint, or lack thereof, in the extreme, and even potentially to officer regret and responsibility in trying to immediately alleviate mistakes.
   
   As the course advances this topic would lend itself to traversing through the data parsing and visualization modules planned. While these are enumerated below, the ultimate task would be to try to parse through reports, using NLP, to add medical resource utilization to the known outcomes of TRR reports, either through parsing reports or inclusion of civil suits. This data, currently not included in attributes, would provide strong additional evidence to explore individual and societal impact.

## Running the code
In order to run the code snippets below, you can either copy the code into a SQL interpreter or run the corresponding SQL question file in src.

## Questions
 1)	[What percentage of use of force incidents result in injury for citizens? Police officers? Broken down by race, age, neighborhood, 
 use of force (physical, taser, firearm, etc.), and other demographics?](#Question-1) 
 2)	[Are there differences in injury pattern in relation to different types of uses of force, i.e. taser vs. firearms vs. other, 
 stratified by race?](#Question-2)
 3)	[Are neighborhoods with higher rates of officer injury reports more likely to be associated with complaints and use of force fillings?](#Question-3) 
 4)	[Are individual officers more likely to be involved in use of force incidents that lead to injury?](#Question-4)
 5)	[Are individual officers more likely to underreport injuries - ie are they less likely to report injury in TRR when injury is alleged 
 by a complainant?](#Question-5)

## Question 1:
Question_1.sql
What percentage of use of force incidents result in injury for citizens? Police officers? Broken down by race, age, neighborhood, 
 use of force (physical, taser, firearm, etc.), and other demographics?

--The following code computes totals and percentages of use of force events that result in injuries
```
--Total counts and percentages for injury data from TRR
SELECT count(*) as total_use_of_force_incidents,
       Count(CASE WHEN subject_injured = 'true' THEN 1 END) AS total_subject_injuries,
       (Count(CASE WHEN subject_injured = 'true' THEN 1 END) * 100) / Count(*) AS percent_subject_injuries,
       Count(CASE WHEN officer_injured = 'true' THEN 1 END) AS total_officer_injuries,
       (Count(CASE WHEN officer_injured = 'true' THEN 1 END) * 100) / Count(*) AS percent_officer_injuries,
       Count(CASE WHEN subject_alleged_injury = 'true' THEN 1 END) AS total_alleged_subject_injuries,
       (Count(CASE WHEN subject_alleged_injury = 'true' THEN 1 END)* 100) / Count(*) AS percent_alleged_subject_injuries,
       (Count(CASE WHEN subject_alleged_injury = 'true' AND NOT subject_injured = 'true'  THEN 1 END) * 100) /
       Count(CASE WHEN subject_alleged_injury = 'true' THEN 1 END) AS percent_subject_alleged_injuries_not_counted,
       cast(count(CASE WHEN officer_injured = 'true' THEN 1 END) AS FLOAT)/cast(count(o) AS FLOAT) AS officer_injuries_per_officer,
       cast(count(CASE WHEN subject_injured = 'true' THEN 1 END) AS FLOAT)/cast(count(o) AS FLOAT) AS subject_injuries_per_officer
FROM trr_trr t
LEFT JOIN data_officer as o on o.id = t.officer_id;
```

--The following code computes subject injuries by subject and officer race
```
--Subject injury broken down by subject race
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

--Subject injury broken down by officer race
SELECT d.race AS officer_race,
       count(*) AS total_use_of_force_events,
       count(CASE WHEN subject_injured = 'true' THEN 1 END) AS subject_injuries,
       count(CASE WHEN subject_injured = 'true' THEN 1 END)*100/count(*) AS percent_subject_injuries,
       count(CASE WHEN subject_alleged_injury = 'true' THEN 1 END) AS subject_alleged_injuries,
       count(CASE WHEN subject_alleged_injury = 'true' AND subject_injured != 'true' THEN 1 END)*100/
       count(CASE WHEN subject_alleged_injury = 'true' THEN 1 END) AS percent_subject_alleged_injuries_not_counted
FROM trr_trr
JOIN data_officer d on d.id = trr_trr.officer_id
GROUP BY d.race
ORDER BY total_use_of_force_events DESC;

--Subject and officer injury broken down by subject race and officer race
SELECT subject_race,
       d.race AS officer_race,
       count(CASE WHEN subject_injured = 'true' THEN 1 END)*100/nullif(count(*),0) AS percent_subject_injuries,
       count(CASE WHEN officer_injured = 'true' THEN 1 END)*100/nullif(count(*),0) AS percent_officer_injuries
FROM trr_trr
JOIN data_officer d on d.id = trr_trr.officer_id
GROUP BY subject_race, d.race
ORDER BY percent_subject_injuries DESC;
```

--The following code computes subject injuries by subject age
```
--Subject injury broken down by subject age
SELECT CASE WHEN subject_age BETWEEN 0 AND 18 THEN '0-18'
    WHEN subject_age BETWEEN 18 AND 40 THEN '18-40'
    WHEN subject_age BETWEEN 40 AND 65 THEN '40-65'
    WHEN subject_age > 65 THEN '>65' END AS age_group,
       count(*) AS total_use_of_force_events,
       count(CASE WHEN subject_injured = 'true' THEN 1 END) AS subject_injuries,
       count(CASE WHEN subject_alleged_injury = 'true' THEN 1 END) AS subject_alleged_injuries,
       count(CASE WHEN subject_injured = 'true' THEN 1 END)*100/count(*) AS percent_subject_injuries
FROM trr_trr
GROUP BY age_group
ORDER BY age_group;
```

--The following code computes subject injuries by gender of subject and gender of officer
```
--Subject and officer injury broken down by gender of subject
SELECT subject_gender,
       count(CASE WHEN subject_injured = 'true' THEN 1 END)*100/count(*) AS percent_subject_injuries,
       count(CASE WHEN officer_injured = 'true' THEN 1 END)*100/count(*) AS percent_officer_injuries
FROM trr_trr
GROUP BY subject_gender
ORDER BY subject_gender;

--Subject and officer injury broken down by gender of officer
SELECT d.gender AS officer_gender,
       count(CASE WHEN subject_injured = 'true' THEN 1 END)*100/nullif(count(*),0) AS percent_subject_injuries,
       count(CASE WHEN officer_injured = 'true' THEN 1 END)*100/nullif(count(*),0) AS percent_officer_injuries
FROM trr_trr
JOIN data_officer d on d.id = trr_trr.officer_id
GROUP BY d.gender
ORDER BY d.gender;
```

--The following code computes subject and officer injuries by taser and firearm use
```
--Subject and officer injuries broken down by whether a firearm was used
SELECT firearm_used,
       count(CASE WHEN subject_injured = 'true' THEN 1 END)*100/nullif(count(*),0) AS percent_subject_injuries,
       count(CASE WHEN officer_injured = 'true' THEN 1 END)*100/nullif(count(*),0) AS percent_officer_injuries
FROM trr_trr
GROUP BY firearm_used
ORDER BY firearm_used;

--Subject and officer injuries broken down by whether a taser was used
SELECT taser,
       count(CASE WHEN subject_injured = 'true' THEN 1 END)*100/nullif(count(*),0) AS percent_subject_injuries,
       count(CASE WHEN officer_injured = 'true' THEN 1 END)*100/nullif(count(*),0) AS percent_officer_injuries
FROM trr_trr
GROUP BY taser
ORDER BY taser;
```

--The following code finds the top 10 beats (neighborhoods) for citizen injury by police
```
--Top 10 beats (neighborhoods) for subject injuries
SELECT beat,
       count(*) AS total_use_of_force_events,
       count(CASE WHEN subject_injured = 'true' THEN 1 END) AS subject_injuries,
       count(CASE WHEN officer_injured = 'true' THEN 1 END) AS officer_injuries,
       count(CASE WHEN subject_injured = 'true' THEN 1 END)*100/nullif(count(*),0) AS percent_subject_injuries,
       count(CASE WHEN officer_injured = 'true' THEN 1 END)*100/nullif(count(*),0) AS percent_officer_injuries
FROM trr_trr
JOIN data_officer d on d.id = trr_trr.officer_id
GROUP BY beat
HAVING count(*)>10
ORDER BY subject_injuries DESC
LIMIT 10;
```

## Question 2:
 Question_2.sql
Are there differences in injury pattern in relation to different types of uses of force, i.e. taser vs. firearms vs. other, 
 stratified by race?
 
 --The following code evaluates firearm and taser use broken down by officer and subject race
```
--Firearm/taser usage broken down by officer race
SELECT d.race as officer_race,
       count(CASE WHEN firearm_used = 'true' THEN 1 END) AS total_firearm,
       count(CASE WHEN firearm_used = 'true' THEN 1 END)*100/count(*) AS percent_firearm,
       count(CASE WHEN taser = 'true' THEN 1 END) AS total_taser,
       count(CASE WHEN taser = 'true' THEN 1 END)*100/count(*) AS percent_taser
From trr_trr
JOIN data_officer d on d.id = trr_trr.officer_id
GROUP BY d.race
ORDER BY d.race;

--Firearm/taser usage broken down by subject race
SELECT subject_race,
       count(CASE WHEN firearm_used = 'true' THEN 1 END) AS total_firearm,
       count(CASE WHEN firearm_used = 'true' THEN 1 END)*100/count(*) AS percent_firearm,
       count(CASE WHEN taser = 'true' THEN 1 END) AS total_taser,
       count(CASE WHEN taser = 'true' THEN 1 END)*100/count(*) AS percent_taser
From trr_trr
GROUP BY subject_race
ORDER BY subject_race;
```

--The following code computes likelihood of injury broken down by weapon type
```
--Likelihood of injury broken down by weapon type
SELECT tw.weapon_type,
       count(*) AS total_use_of_force_events,
       count(CASE WHEN subject_injured = 'true' THEN 1 END) AS subject_injuries,
       count(CASE WHEN subject_injured = 'true' THEN 1 END)*100/nullif(count(*),0) AS percent_subject_injuries
FROM trr_trr t
JOIN trr_weapondischarge tw on tw.trr_id = t.id
GROUP BY tw.weapon_type
ORDER BY percent_subject_injuries;
```

--The following code computes likelihood of injury for different types of uses of force broken down by subject race
```
--Taser use of force events broken down by subject race
SELECT subject_race,
       count(*) AS total_use_of_force_events,
       count(CASE WHEN subject_injured = 'true' THEN 1 END) AS subject_injuries,
       count(CASE WHEN subject_injured = 'true' THEN 1 END)*100/nullif(count(*),0) AS percent_subject_injuries
FROM trr_trr
JOIN data_officer d on d.id = trr_trr.officer_id
WHERE taser = 'true'
GROUP BY subject_race
ORDER BY percent_subject_injuries DESC;

--Firearm use of force broken down by subject_race
SELECT subject_race,
       count(*) AS total_use_of_force_events,
       count(CASE WHEN subject_injured = 'true' THEN 1 END) AS subject_injuries,
       count(CASE WHEN subject_injured = 'true' THEN 1 END)*100/nullif(count(*),0) AS percent_subject_injuries
FROM trr_trr
JOIN data_officer d on d.id = trr_trr.officer_id
WHERE firearm_used = 'true'
GROUP BY subject_race
ORDER BY percent_subject_injuries DESC;

--Firearm use of force broken down by subject_race
SELECT subject_race,
       count(*) AS total_use_of_force_events,
       count(CASE WHEN subject_injured = 'true' THEN 1 END) AS subject_injuries,
       count(CASE WHEN subject_injured = 'true' THEN 1 END)*100/nullif(count(*),0) AS percent_subject_injuries
FROM trr_trr
JOIN data_officer d on d.id = trr_trr.officer_id
WHERE firearm_used = 'false' AND taser='false'
GROUP BY subject_race
ORDER BY percent_subject_injuries DESC;
```

## Question 3:
Are neighborhoods with higher rates of officer injury reports more likely to be associated with subject injuries or total number of events.  

-- This code will answer question 3 of checkpoint 1:
-- Please open question_3.sql and run the code: code as follows:
-- to view the tables in different orders, just replace order by with the appropriate column header
  
	SELECT beat, count(*) total_events,
		count(case when officer_injured = 'True' then 1 end) as officer_injured,
		count(case when officer_injured = 'True' then 1 end)*100/count(*) as percent_officer_injured,
		count(case when subject_injured = 'True' then 1 end) as subject_injured,
		count(case when subject_injured = 'True' then 1 end)*100/count(*) as percent_subject_injured
	from trr_trr
	group by beat
	order by officer_injured desc;


## Question 4:
Are individual officers more likely to be involved with in use of force incidents that lead to injury?

-- This code will answer question 4 of checkpoint 1:
-- Please open question_4.sql : code as follows
  -- to view the tables in different orders, just replace order by with the appropriate column header
	
	SELECT officer_id, count(*) as total_use_of_force_events,
		count(case when subject_injured = 'True' then 1 end) as subject_injured,
		count(case when subject_injured = 'True' then 1 end)*100/count(*) as_percent_of_events
	from trr_trr
	group by officer_id
	order by subject_injured desc;
  
## Question 5: 
Are individual officers more likely to underreport injuries - ie are they less likely to report injury in TRR when injury is alleged 
by a complainant?
 
For question 5 code is found in the question_5.sql file.
First generate temporary tables by running Code from question_5.sql lines 0-52: Code as follows

	DROP TABLE IF EXISTS force_allegation_counts;
	CREATE TEMP TABLE force_allegation_counts AS
		(SELECT da.officer_id,
		count(CASE WHEN dc.category = 'Use Of Force' THEN 1 END) AS total_use_of_force_complaints
		FROM data_officerallegation da
		JOIN data_allegationcategory dc on dc.id = da.allegation_category_id
		GROUP BY da.officer_id
		ORDER BY total_use_of_force_complaints DESC)
	;

	DROP TABLE IF EXISTS officer_trrs;
	CREATE TEMP TABLE  officer_trrs AS
	(SELECT officer_id,
		count(*) AS total_use_of_force_events,
		count(CASE WHEN subject_injured = 'true' AND subject_alleged_injury = 'true' THEN 1 END) AS subject_injuries,
		count(CASE WHEN officer_injured = 'true' THEN 1 END) AS officer_injuries,
		count(CASE WHEN subject_alleged_injury = 'true' THEN 1 END) AS alleged_injuries,
		count(CASE WHEN subject_injured = 'true' THEN 1 END)*100/nullif(count(*),0) AS percent_subject_injuries,
		count(CASE WHEN officer_injured = 'true' THEN 1 END)*100/nullif(count(*),0) AS percent_officer_injuries,
		count(CASE WHEN subject_alleged_injury = 'true' AND subject_injured != 'true' THEN 1 END)*100/
		nullif(count(CASE WHEN subject_alleged_injury = 'true' THEN 1 END), 0) AS percent_subject_alleged_injuries_not_counted,
		count(CASE WHEN firearm_used = 'true' THEN 1 END)*100/nullif(count(*),0) AS firearm_dicharged,
		count(CASE WHEN taser = 'true' THEN 1 END)*100/nullif(count(*),0) AS taser_used,
		cast(count(CASE WHEN subject_alleged_injury = 'true' THEN 1 END) AS FLOAT)/
		nullif(cast(count(CASE WHEN subject_injured = 'true' THEN 1 END) AS FLOAT), 0) AS ratio_of_alleged_to_reported_injury
	FROM trr_trr
	JOIN data_officer d on d.id = trr_trr.officer_id
	GROUP BY officer_id
	HAVING count(*)>10
	ORDER BY total_use_of_force_events DESC)
	;

	DROP TABLE IF EXISTS complaint_percentages;
	CREATE TEMP TABLE  complaint_percentages AS
	(
		SELECT ot.officer_ID,
		total_use_of_force_events,
		fac.total_use_of_force_complaints,
		(100 * fac.total_use_of_force_complaints / ot.total_use_of_force_events) AS Percent_complaint
	FROM officer_trrs ot
		JOIN force_allegation_counts fac on ot.officer_id = fac.officer_id
	order by Percent_complaint DESC
	);

	DROP TABLE IF EXISTS alleged_injuries_not_counted;
	CREATE TEMP TABLE  alleged_injuries_not_counted AS
	(
	SELECT officer_ID, alleged_injuries,subject_injuries, percent_subject_alleged_injuries_not_counted
	FROM officer_trrs
	WHERE percent_subject_alleged_injuries_not_counted is NOT NULL and alleged_injuries >9
	order by percent_subject_alleged_injuries_not_counted DESC)
	;

Then to view complaint percentages table, table 5-1 as above please run codes from line 55 to 57

	SELECT *
	from complaint_percentages
	Limit 20;

To view the average numberof complaints referenced above run the code from line 60 to 61

	SELECT AVG(percent_complaint)
	FROM complaint_percentages;

To view table 5.2 “Alleged Injuries not counted” run the code from line 64 to 66

	SELECT *
	from alleged_injuries_not_counted
	limit 20;

To view the average of all officers percentage of alleged_injureis not counted run the code from line 69 to 70

	SELECT AVG(percent_subject_alleged_injuries_not_counted)
	FROM officer_trrs;

To view the average of officers percentage of alleged_injureis not counted who have 10 or more injuries alleged, run the code from line 73 to 74

	SELECT AVG(percent_subject_alleged_injuries_not_counted)
	FROM alleged_injuries_not_counted;
