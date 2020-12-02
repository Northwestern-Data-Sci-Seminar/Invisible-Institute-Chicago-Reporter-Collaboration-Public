/* Initial query for getting the summaries and associated data from the original CPDP database*/

SELECT oa.allegation_id as allegation_id,
       oa.allegation_category_id as category_id,
       ac.category as category,
       oa.final_outcome as final_outcome,
       a.summary as summary
FROM data_officerallegation oa
    INNER JOIN data_allegationcategory ac on oa.allegation_category_id = ac.id
    INNER JOIN data_allegation a on oa.allegation_id = a.crid
WHERE a.summary > '';


/* Create a new table for the extra narratives */

CREATE TABLE data_narratives (
    id SERIAL,
    cr_id varchar(30),
    summary text,
    PRIMARY KEY (id)
);


/* Query for inserting the csv for this data into the new table */

COPY data_narratives(cr_id, summary)
FROM '/Users/stermark/Desktop/cs496_data_science_seminar/test/all_narratives.csv'
DELIMITER ','
CSV HEADER;

/* Query for getting a unified view of the allegations with their associated summaries/narratives */

SELECT oa.allegation_id as allegation_id,
       oa.allegation_category_id as category_id,
       ac.category as category,
       oa.final_outcome as final_outcome,
       n.summary as summary
FROM data_officerallegation oa
    INNER JOIN data_allegationcategory ac on oa.allegation_category_id = ac.id
    INNER JOIN data_narratives n on oa.allegation_id = n.cr_id
WHERE n.summary > '';


/* Query for getting the complaints that have no known category AND have a summary */

SELECT oa.allegation_id as allegation_id,
       oa.allegation_category_id as category_id,
       ac.category as category,
       oa.final_outcome as final_outcome,
       a.summary as summary
FROM data_officerallegation oa
    LEFT JOIN data_allegationcategory ac on oa.allegation_category_id = ac.id
    LEFT JOIN data_allegation a on oa.allegation_id = a.crid
WHERE (ac.category = 'Unknown' OR ac.category IS NULL)
  AND a.summary > '';


/* Other queries for testing */

CREATE TABLE data_narratives (
    id SERIAL,
    cr_id varchar(30),
    pdf_name varchar,
    page_num integer,
    section_name varchar,
    column_name varchar,
    text text,
    batch_id integer,
    dropbox_path text,
    doccloud_url text,
    PRIMARY KEY (id)
);

COPY data_narratives(cr_id, pdf_name, page_num, section_name, column_name, text, batch_id, dropbox_path, doccloud_url)
FROM '/Users/stermark/Desktop/cs496_data_science_seminar/test/all_narratives.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM data_narratives;

DROP TABLE data_narratives;

SELECT cr_id, text as summary, column_name
FROM data_narratives
WHERE NOT (text = '(None Entered)'
OR text = 'NO AFFIDAVIT')
AND (column_name = 'Initial / Intake Allegation'
OR column_name = 'Allegation');


WITH nar as (SELECT cr_id, text as summary
             FROM data_narratives
             WHERE NOT (text = '(None Entered)'
                    OR text = 'NO AFFIDAVIT')
                AND (column_name = 'Initial / Intake Allegation'
                    OR column_name = 'Allegation'))
SELECT a.crid, nar.cr_id, nar.summary, a.summary
FROM data_allegation a
FULL OUTER JOIN nar on a.crid = nar.cr_id
WHERE a.summary > '' OR nar.summary IS NOT NULL;

SELECT * FROM data_allegation;



WITH nar as (SELECT cr_id, text as summary
             FROM data_narratives
             WHERE NOT (text = '(None Entered)'
                    OR text = 'NO AFFIDAVIT')
                AND (column_name = 'Initial / Intake Allegation'
                    OR column_name = 'Allegation'))
WITH all_allegations as (SELECT crid
    FROM data_allegation a
    INNER JOIN nar on a.crid = nar.cr_id)
SELECT oa.allegation_id as allegation_id,
       oa.allegation_category_id as category_id,
       ac.category as category,
       oa.final_outcome as final_outcome,
       a.summary as summary
FROM data_officerallegation oa
    INNER JOIN data_allegationcategory ac on oa.allegation_category_id = ac.id
    INNER JOIN data_allegation a on oa.allegation_id = a.crid
WHERE a.summary > '';