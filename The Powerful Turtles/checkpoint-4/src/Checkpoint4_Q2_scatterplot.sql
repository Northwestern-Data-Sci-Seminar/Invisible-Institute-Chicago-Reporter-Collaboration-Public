-- Representative race for each community
DROP TABLE IF EXISTS community_race;
CREATE TEMP TABLE community_race
AS (
    SELECT a.area_id, a.race, CAST(a.count AS float) / CAST(b.total_count AS float) AS percentage, a.count, b.total_count
    FROM data_racepopulation a
             INNER JOIN (
        SELECT area_id, SUM(count) total_count
        FROM data_racepopulation
        GROUP BY area_id
    ) b ON a.area_id = b.area_id
);

DROP TABLE IF EXISTS complainant_race;
CREATE TEMP TABLE complainant_race
AS (
    SELECT a.allegation_id, officer_id,
           data_complainant.race as complainant_race
    FROM data_officerallegation as a
             INNER JOIN data_complainant
                             ON a.allegation_id = data_complainant.allegation_id
);

-- Add area id to the table
DROP TABLE IF EXISTS table_with_area;
CREATE TEMP TABLE table_with_area
AS (
    SELECT a.allegation_id, a.officer_id, a.complainant_race, b.area_id
    FROM complainant_race a
    INNER JOIN (
        SELECT *
        FROM data_allegation_areas
    ) b ON a.allegation_id = b.allegation_id
);

DROP TABLE IF EXISTS complainant_percentage;
CREATE TEMP TABLE complainant_percentage
AS (
    SELECT a.allegation_id, a.officer_id, a.area_id, a.complainant_race, b.percentage AS complainant_percentage
    FROM table_with_area a
    INNER JOIN (
        SELECT *
        FROM community_race
    ) b ON a.area_id = b.area_id AND a.complainant_race = b.race
);

DROP TABLE IF EXISTS officer_races;
CREATE TEMP TABLE officer_races
AS(
    SELECT a.allegation_id, a.area_id, a.complainant_race, b.race AS officer_race, a.complainant_percentage
    FROM complainant_percentage as a
    INNER JOIN (
            SELECT id, race From data_officer
        ) b ON a.officer_id = b.id
);

DROP TABLE IF EXISTS both_percentage;
CREATE TEMP TABLE both_percentage
AS (
    SELECT a.allegation_id, a.officer_race, b.percentage AS officer_percentage, a.complainant_race, a.complainant_percentage
    FROM officer_races a
    INNER JOIN (
        SELECT *
        FROM community_race
    ) b ON a.area_id = b.area_id AND a.officer_race = b.race
);

SELECT * FROM both_percentage;