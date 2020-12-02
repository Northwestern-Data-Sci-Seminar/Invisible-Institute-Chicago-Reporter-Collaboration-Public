--SQL Code for Question 2

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

--Likelihood of injury broken down by weapon type
SELECT tw.weapon_type,
       count(*) AS total_use_of_force_events,
       count(CASE WHEN subject_injured = 'true' THEN 1 END) AS subject_injuries,
       count(CASE WHEN subject_injured = 'true' THEN 1 END)*100/nullif(count(*),0) AS percent_subject_injuries
FROM trr_trr t
JOIN trr_weapondischarge tw on tw.trr_id = t.id
GROUP BY tw.weapon_type
ORDER BY percent_subject_injuries;

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


