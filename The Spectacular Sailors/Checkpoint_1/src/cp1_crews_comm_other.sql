-- Question 1: Who are the police officers according to their membership across three distinct cohorts
-- (“the Cohorts”): (1) in a crew, (2) in a community, (3) not in a crew and not in a community?
-- For instance, along the following data points:
--              Individual Police Officer Demographics
--              Counts of accusals, co-accusals, and disciplinary actions
--              Award payouts

-- Q1 Part A: Identify Officers by Cohort

-- Create a base table of officers in crews and in communities
DROP TABLE IF EXISTS working_cohort_0;
CREATE TEMP TABLE working_cohort_0 AS (
    SELECT doc.officer_id, doc.crew_id, doc.officer_name, dc.detected_crew
    FROM data_officercrew doc
    LEFT JOIN data_crew dc
        on doc.crew_id = dc.community_id
    WHERE doc.crew_id in (
        SELECT dc.community_id
        FROM data_crew
        )
);

SELECT * FROM working_cohort_0;

-- Cohort 1 Crews: ~1,156
SELECT COUNT(DISTINCT officer_id)
FROM working_cohort_0
WHERE detected_crew = 'true';

-- Cohort 2 Community and not Crew: ~10,071
SELECT COUNT(DISTINCT officer_id)
FROM working_cohort_0
WHERE detected_crew = 'false';

-- Find all officers who are not in crews or communities (Cohort 3)
SELECT "do".id, "do".first_name, "do".last_name
FROM data_officer "do"
LEFT JOIN working_cohort_0 oc ON
    "do".id = oc.officer_id
WHERE oc.officer_id is NULL;

-- Cohort 3 count: All Other Officers ~ 23,780
SELECT COUNT(DISTINCT "do".id)
FROM data_officer "do"
LEFT JOIN working_cohort_0 oc ON
    "do".id = oc.officer_id
WHERE oc.officer_id is NULL;

-- Total Officer Population: ~ 35,007
SELECT COUNT(DISTINCT id)
FROM data_officer;

--  Working Notes
--      when detected_crew = true, cohorts is 1 (crew),
--      when detected_crew = false, cohorts is 2 (community),
--      when condition is all other officers, cohorts is 3 (community),

DROP TABLE IF EXISTS working_cohort_3;
CREATE TEMP TABLE working_cohort_3 AS (
    SELECT "do".id as officer_id,
           CONCAT("do".first_name, "do".last_name) AS officer_name
    FROM data_officer "do"
    LEFT JOIN working_cohort_0 oc ON
        "do".id = oc.officer_id
    WHERE oc.officer_id is NULL
    );


DROP TABLE IF EXISTS officers_cohorts;
CREATE TEMP TABLE officers_cohorts AS (
    SELECT officer_id, NULL as crew_id, officer_name, NULL as detected_crew, 3 as cohort
    FROM working_cohort_3
    UNION
    SELECT officer_id, crew_id, officer_name, detected_crew, NULL as cohort
    FROM working_cohort_0
);

UPDATE officers_cohorts
    SET cohort = (CASE WHEN cohort IS NULL THEN (CASE WHEN detected_crew = 'true' THEN 1 ELSE 2 END) ELSE cohort END);

ALTER TABLE officers_cohorts
    ADD community_id int;

UPDATE officers_cohorts
    SET community_id = (CASE WHEN detected_crew = 'false' THEN crew_id ELSE 0 END);

UPDATE officers_cohorts
    SET crew_id = (CASE WHEN detected_crew = 'true' THEN crew_id ELSE 0 END);

ALTER TABLE officers_cohorts
    DROP detected_crew;

-- Return a table of officers by cohort
-- When crew_id is 0, then not in a crew
-- When community_id is 0, then not in a community
-- When cohort = 1, then crew, when cohort = 2, then community, when cohort = 3, then all others

-- View officers_cohorts table
SELECT * FROM officers_cohorts;

-- Return counts as a table
DROP TABLE IF EXISTS officers_cohorts_countstotal;
CREATE TEMP TABLE officers_cohorts_countstotal AS (
SELECT cohort, COUNT(DISTINCT officer_id)  as total_officers
FROM officers_cohorts
GROUP BY cohort);

-- View officers counts table
SELECT * FROM officers_cohorts_countstotal


-- Q1 Part B: Join accusals and disciplinary data to officers_cohorts

-- Return allegation and officer data for all officers based on cohorts
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
    group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17, 18
);

-- View the result of query 1 breakouts by cohort
SELECT * FROM officers_cohorts_data;


-- Data Note: The total population of officers is reduced to 23,444 (not all officers have allegations)
-- There are 23,444 distinct officer IDs in data_officer_allegation
DROP TABLE IF EXISTS officers_cohorts_countsallegation;
CREATE TEMP TABLE officers_cohorts_countsallegation AS (
    SELECT cohort, COUNT(DISTINCT officer_id) as officers_with_allegations
    FROM officers_cohorts_data
    GROUP BY cohort
);

-- View subtotal counts of officers with at least one allegation
SELECT * FROM officers_cohorts_countsallegation;

-- Question 2: Within each Cohort, what is the average number of co-accusals per individual complaint?
-- Where the average is given by the sum of co-accusals in a Cohort divided by the total number of
-- complaints (where a complaint is a unique CRID).

-- unique complaint count in cohort 1 (20174 counts)
SELECT count(Distinct crid)
FROM officers_cohorts_data
WHERE cohort = '1';

-- create sub-table with all officers in cohort 1 (in a crew)
DROP TABLE IF EXISTS officers_cohorts_1;
CREATE TEMP TABLE officers_cohorts_1 AS (
    SELECT ocd.officer_id, ocd.crid, ocd.cohort, ocd.coaccused_count
    FROM officers_cohorts_data ocd
    WHERE cohort = '1'
);

-- create a table with all rows of distinct crid for cohort 1
DROP TABLE IF EXISTS officers_cohorts_coaccusal1;
CREATE TEMP TABLE officers_cohorts_coaccusal1 AS (
    SELECT oc1.officer_id, oc1.crid, oc1.cohort, oc1.coaccused_count
    FROM officers_cohorts_1 oc1
    JOIN (SELECT crid, min(officer_id) as minid from officers_cohorts_1 group by crid) x
    ON x.crid = oc1.crid
    AND x.minid = oc1.officer_id
);

-- validates count if it's having distinct crid, (20174 counts)
SELECT count(*) as sum_com1
FROM officers_cohorts_coaccusal1;

-- sum of co-accusals in cohort 1 (56294 times)
SELECT SUM(coaccused_count) as sum_coa1
FROM officers_cohorts_coaccusal1;

-- Return AVG coaccused_count for cohort 1
SELECT AVG(coaccused_count) FROM officers_cohorts_coaccusal1;

-- unique complaint count in cohort 2 (96651 counts)
SELECT count(Distinct crid)
FROM officers_cohorts_data
WHERE cohort = '2';

-- create sub-table with all officers in cohort 2 (in a crew)
DROP TABLE IF EXISTS officers_cohorts_2;
CREATE TEMP TABLE officers_cohorts_2 AS (
    SELECT ocd.officer_id, ocd.crid, ocd.cohort, ocd.coaccused_count
    FROM officers_cohorts_data ocd
    WHERE cohort = '2'
);

-- create a table with all rows of distinct crid for cohort 2
DROP TABLE IF EXISTS officers_cohorts_coaccusal2;
CREATE TEMP TABLE officers_cohorts_coaccusal2 AS (
    SELECT oc2.officer_id, oc2.crid, oc2.cohort, oc2.coaccused_count
    FROM officers_cohorts_2 oc2
    JOIN (SELECT crid, min(officer_id) as minid from officers_cohorts_2 group by crid) y
    ON y.crid = oc2.crid
    AND y.minid = oc2.officer_id
);

-- validates count if it's having distinct crid, (96651 counts)
SELECT count(*) as sum_com2
FROM officers_cohorts_coaccusal2;

-- sum of co-accusals in cohort 2 (196844 times)
SELECT SUM(coaccused_count) as sum_coa2
FROM officers_cohorts_coaccusal2;

-- Return average coaccused_count for cohort 2
SELECT AVG(coaccused_count) FROM officers_cohorts_coaccusal2;

-- unique complaint count in cohort 3 (47137 counts)
SELECT count(Distinct crid)
FROM officers_cohorts_data
WHERE cohort = '3';

-- create sub-table with all officers in cohort 3 (in a crew)
DROP TABLE IF EXISTS officers_cohorts_3;
CREATE TEMP TABLE officers_cohorts_3 AS (
    SELECT ocd.officer_id, ocd.crid, ocd.cohort, ocd.coaccused_count
    FROM officers_cohorts_data ocd
    WHERE cohort = '3'
);

-- create a table with all rows of distinct crid for cohort 3
DROP TABLE IF EXISTS officers_cohorts_coaccusal3;
CREATE TEMP TABLE officers_cohorts_coaccusal3 AS (
    SELECT oc3.officer_id, oc3.crid, oc3.cohort, oc3.coaccused_count
    FROM officers_cohorts_3 oc3
    JOIN (SELECT crid, min(officer_id) as minid from officers_cohorts_3 group by crid) z
    ON z.crid = oc3.crid
    AND z.minid = oc3.officer_id
);

-- validates count if it's having distinct crid, (47137 counts)
SELECT count(*) as sum_com3
FROM officers_cohorts_coaccusal3;

-- sum of co-accusals in cohort 3 (91000 times)
SELECT SUM(coaccused_count) as sum_coa3
FROM officers_cohorts_coaccusal3;

-- Return average coaccused_count for cohort 3
SELECT AVG(coaccused_count) FROM officers_cohorts_coaccusal3;

-- combine averge coaccusal results into table for export and analysis
-- Officer Counts by Cohort

DROP TABLE IF EXISTS officers_cohorts_coaccused;
CREATE TEMP TABLE officers_cohorts_coaccused AS (
    SELECT *
    FROM officers_cohorts_coaccusal3
    UNION
    SELECT *
    FROM officers_cohorts_coaccusal2
    UNION
    SELECT *
    FROM officers_cohorts_coaccusal1
);

-- view result from above
SELECT * FROM officers_cohorts_coaccused;

-- Return a count of officers_cohorts_coaccused_counts
DROP TABLE IF EXISTS officers_cohorts_coaccused_counts;
CREATE TEMP TABLE officers_cohorts_coaccused_counts AS (
    SELECT cohort, COUNT(DISTINCT crid) AS unique_crid_count, AVG(coaccused_count) AS avg_coaccused_count
    FROM officers_cohorts_coaccused
    GROUP BY cohort
);

-- view returned counts with coacussals
SELECT * FROM officers_cohorts_coaccused_counts

DROP TABLE IF EXISTS officers_cohorts_counts;
CREATE TEMP TABLE officers_cohorts_counts AS (
    SELECT officers_cohorts_countstotal.cohort,
           officers_cohorts_countstotal.total_officers,
           occ.officers_with_allegations,
           o.unique_crid_count,
           o.avg_coaccused_count
    FROM officers_cohorts_countstotal
            INNER JOIN officers_cohorts_countsallegation occ on officers_cohorts_countstotal.cohort = occ.cohort
            INNER JOIN officers_cohorts_coaccused_counts o on officers_cohorts_countstotal.cohort = o.cohort
);

-- View Counts table
SELECT * FROM officers_cohorts_counts;

-- Question 3: Within each Cohort, what percentage of allegations results in disciplinary action?
-- Where the percentage is calculated by total allegations in cohort / total times disciplined in cohort.


-- Question 4: For each Cohort, describe the average police officer in terms of demographics, accusals, and payout data.
-- By percentage:
--              Sex
--              Race
--              Age: 21-24; 25-34; 35-44; 45-54; 55-64; 65+
--              Years on the Force: 0-9; 10-14; 15-19; 20-24; 25-29; 30+
-- By Average:
--              Payout data in thousands of dollars
--              Accusations, Disciplinary actions, or percentage from Question 3


