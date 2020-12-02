/*data for figure 1.1 and 1.2 and Race.csv*/
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

/*data for figure 1.3 and 1.4 and Result_63.csv*/
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

/* data for figure 1.5 and 1.6 Result_64.csv*/

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

/*data for figure 2.1 and 2.2 and Districts_HCG.csv
  Due to districts being combined on the map district 12 and 13 are combined.
  Districts 21 23 and 26-30 are not on the map and have not been included*/


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


