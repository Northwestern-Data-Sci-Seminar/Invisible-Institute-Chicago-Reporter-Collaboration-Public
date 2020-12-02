--SQL Code for question 1

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

--Subject and officer injury broken down by officer race
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

--Subject and officer injury broken down by subject age
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
