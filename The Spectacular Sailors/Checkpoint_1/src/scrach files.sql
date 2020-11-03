
/* Milan's Space
SELECT disciplined FROM officers_cohorts_data
where
   disciplined IS Null
   or disciplined = 'False';


DROP TABLE IF EXISTS officers_cohorts_data;
CREATE TEMP TABLE officers_cohorts_data AS (
    SELECT "oc".officer_id,
           "oc".crew_id,
           "oc".community_id,
           "oc".cohort,
           "do".gender,
           "do".race,
           "do".appointed_date,
           "do".active,
           "do".complaint_percentile,
           "do".civilian_allegation_percentile,
           "do".last_unit_id,
           "da".crid,
           "da".incident_date,
           "da".point,
           "da".beat_id,
           "da".location,
           "doa".allegation_category_id,
           case when disciplined IS Null
   or "doa".disciplined = 'False'then 0 when "doa".disciplined = 'true' then 1 end as disciplined_flag,
            "doa".disciplined,
           sum ("da".coaccused_count) as Coaccused_Count

    FROM data_officer "do"
             LEFT JOIN data_officerallegation "doa"
                       on "do".id = "doa".officer_id
             LEFT JOIN data_allegation "da"
                       on "doa".allegation_id = "da".crid
             RIGHT JOIN officers_cohorts "oc"
                       on "doa".officer_id = "oc".officer_id
    WHERE "do".id in (
        SELECT officers_cohorts.officer_id
        FROM officers_cohorts)
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
);

select * from officers_cohorts_data
*/

SELECT * FROM data_officer LIMIT 10;