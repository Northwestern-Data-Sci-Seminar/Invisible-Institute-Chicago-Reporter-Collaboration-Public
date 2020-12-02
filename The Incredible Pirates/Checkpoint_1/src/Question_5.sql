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

/*Percentages of complaints compared to TRRs filed Table 5.1 */
SELECT *
from complaint_percentages
Limit 20;

/*5.1 Average number of percentage of complaints to trr */
SELECT AVG(percent_complaint)
FROM complaint_percentages;

/*Alleged Injuries not counted Tablle 5.2 */
SELECT *
from alleged_injuries_not_counted
limit 20;

/*5.2 Overall Average of Subject_injury not verified in TRR */
SELECT AVG(percent_subject_alleged_injuries_not_counted)
FROM officer_trrs;

/*Average of subject_injury not verified in TRR of officers with >9 TRRs filed */
SELECT AVG(percent_subject_alleged_injuries_not_counted)
FROM alleged_injuries_not_counted;