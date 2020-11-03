/* 1. What is the most common offense/misconduct that leads to discipline? */
SELECT category
FROM data_allegationcategory AS t1
INNER JOIN
(SELECT allegation_category_id AS allegation_category_id_mode
FROM data_officerallegation
WHERE disciplined IS TRUE
GROUP BY allegation_category_id
ORDER BY (COUNT(allegation_category_id)) DESC
LIMIT 1) AS t2
ON t1.id = t2.allegation_category_id_mode;

/* Question 1 follow up - What are the discipline rates for each misconduct category (as opposed to total disciplines)? */
select t6.category, (1.0 * disc_count) / (1.0 * total_count) as disc_percent
from
(SELECT category, COUNT(category) as disc_count
FROM data_allegationcategory AS t1
INNER JOIN
(SELECT allegation_category_id as category_id
FROM data_officerallegation
WHERE disciplined = true
GROUP BY id
ORDER BY COUNT(allegation_category_id) DESC) as t2
on t1.id = t2.category_id
GROUP BY category
ORDER BY COUNT(category)) as t3
FULL OUTER JOIN
(SELECT category, COUNT(category) as total_count
FROM data_allegationcategory AS t4
INNER JOIN
(SELECT allegation_category_id as category_id
FROM data_officerallegation
GROUP BY id
ORDER BY COUNT(allegation_category_id) DESC) as t5
on t4.id = t5.category_id
GROUP BY category
ORDER BY COUNT(category)) as t6
ON t3.category = t6.category
order by disc_percent DESC;


/* 2. What is the most common offense/misconduct that leads to settlement? */
SELECT misconducts from lawsuit_lawsuit
WHERE total_settlement > 0
GROUP BY misconducts
ORDER BY COUNT(*) DESC
LIMIT 1;


/* 3. What is the average number of unit changes over a total career for disciplined vs. not disciplined cops?
*/
/* Disciplined cops */
SELECT avg(unit_changes)
FROM (select data_officerhistory.officer_id as officer_id, count(data_officerhistory.unit_id) as unit_changes
from data_officerhistory
group by officer_id
ORDER BY COUNT(data_officerhistory.unit_id) DESC) as t2
INNER JOIN
(select * from data_officer where discipline_count > 0) as t1
ON t1.id = officer_id;



/* Cops with no history of discipline */
SELECT avg(unit_changes)
FROM (select data_officerhistory.officer_id as officer_id, count(data_officerhistory.unit_id) as unit_changes
from data_officerhistory
group by officer_id
ORDER BY COUNT(data_officerhistory.unit_id) DESC) as t2
INNER JOIN
(select * from data_officer where discipline_count = 0) as t1
ON t1.id = officer_id;


/* 4. What is the type of discipline that officers receive the most? */
SELECT final_outcome FROM data_officerallegation
WHERE disciplined IS TRUE
GROUP BY final_outcome
ORDER BY COUNT(*) DESC
LIMIT 1;


/* !!! ****** Resubmission ****** !!! */

/* Question 2 */
/* What is the most common offense/misconduct that leads to settlement? */
/* The difference between this query and the one above is here we look at every misconduct category individually, even if they occur together */
SELECT '%False arrest or report%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%False arrest or report%'
union
SELECT '%Excessive force%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Excessive force%'
union
SELECT '%Threats/intimidation%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Threats/intimidation%'
union
SELECT '%Illegal search/seizure%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Illegal search/seizure%'
union
SELECT '%Destroy/conceal/fabricate evidence%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Destroy/conceal/fabricate evidence%'
union
SELECT '%Damage to property%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Damage to property%'
union
SELECT '%Stolen property%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Stolen property%'
union
SELECT '%Racial epithets%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Racial epithets%'
union
SELECT '%Strip search%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Strip search%'
union
SELECT '%Shooting%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Shooting%'
union
SELECT '%Pattern/practice of misconduct%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Pattern/practice of misconduct%'
union
SELECT '%Witness manipulation%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Witness manipulation%'
union
SELECT '%Failure to provide medical care%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Failure to provide medical care%'
union
SELECT '%Sexual harassment/abuse%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Sexual harassment/abuse%'
union
SELECT '%Forced confession%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Forced confession%'
union
SELECT '%Legal access denied%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Legal access denied%'
union
SELECT '%Torture%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Torture%'
union
SELECT '%Bribery%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Bribery%'
union
SELECT '%Retaliation%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Retaliation%'
union
SELECT '%Not misconduct%', count(*) from lawsuit_lawsuit
WHERE total_settlement > 0 and CAST(misconducts as varchar) LIKE '%Not misconduct%';

/* Question 3 */
/* Which units/beats have the most disciplined cops? */
select unit, beat, count(*) from
(select distinct unit, beat, officer_id from data_officerassignmentattendance as t1
inner join
(select * from data_officer where discipline_count > 0) as t2
on t1.officer_id = t2.id) as t3
group by unit, beat
order by count(*) desc;