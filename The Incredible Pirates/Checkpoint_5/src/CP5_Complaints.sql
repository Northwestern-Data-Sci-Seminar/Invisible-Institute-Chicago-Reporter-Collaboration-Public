select id, name
from data_area
where area_type='beat';

DROP TABLE IF EXISTS sumy;
Create TEMP Table sumy as
    (
    SELECT crid, CAST(name as int) as beatt_id
    from data_allegation
    left join data_area
    on data_allegation.beat_id = data_area.id
    )

select * from sumy;


DROP TABLE IF EXISTS sum1;
Create TEMP Table sum1 as
    (
    SELECT data_attachmentfile.id, allegation_id, sumy.beatt_id as beat_id
    from data_attachmentfile
    left join sumy
    on data_attachmentfile.allegation_id = sumy.crid
    )


select * from sum1;

select distinct beat_id from sum1;

/*Link beat_id to district name */
DROP TABLE IF EXISTS sum2;
CREATE TEMP TABLE sum2 AS
    (
        SELECT id,
               CASE
                   WHEN beat_id BETWEEN 100 AND 199 THEN '1st'
                   WHEN beat_id BETWEEN 200 AND 299 THEN '2nd'
                   WHEN beat_id BETWEEN 300 AND 399 THEN '3rd'
                   WHEN beat_id BETWEEN 400 AND 499 THEN '4th'
                   WHEN beat_id BETWEEN 500 AND 599 THEN '5th'
                   WHEN beat_id BETWEEN 600 AND 699 THEN '6th'
                   WHEN beat_id BETWEEN 700 AND 799 THEN '7th'
                   WHEN beat_id BETWEEN 800 AND 899 THEN '8th'
                   WHEN beat_id BETWEEN 900 AND 999 THEN '9th'
                   WHEN beat_id BETWEEN 1000 AND 1099 THEN '10th'
                   WHEN beat_id BETWEEN 1100 AND 1199 THEN '11th'
                   WHEN beat_id BETWEEN 1200 AND 1399 THEN '12th'
                   WHEN beat_id BETWEEN 1400 AND 1499 THEN '14th'
                   WHEN beat_id BETWEEN 1500 AND 1599 THEN '15th'
                   WHEN beat_id BETWEEN 1600 AND 1699 THEN '16th'
                   WHEN beat_id BETWEEN 1700 AND 1799 THEN '17th'
                   WHEN beat_id BETWEEN 1800 AND 1899 THEN '18th'
                   WHEN beat_id BETWEEN 1900 AND 1999 THEN '19th'
                   WHEN beat_id BETWEEN 2000 AND 2099 THEN '20th'
                   WHEN beat_id BETWEEN 2200 AND 2299 THEN '22nd'
                   WHEN beat_id BETWEEN 2400 AND 2499 THEN '24th'
                   WHEN beat_id BETWEEN 2500 AND 2599 THEN '25th'
                   WHEN beat_id BETWEEN 3100 AND 3199 THEN '31th'
                   END AS district_name
        FROM sum1
        GROUP BY id,allegation_id, beat_id
    )

select count(distinct district_name) from sum2

select * from sum2;

DROP TABLE IF EXISTS Summary;
CREATE TEMP TABLE Summary AS
    (
        SELECT summary as summ,id,null as attachment_id from lawsuit_lawsuit
        UNION
        SELECT text_content as summ,id, attachment_id from data_attachmentnarrative
    )

/* used this to check to make sure IDS did not overlap
SELECT id
FROM data_attachmentnarrative
WHERE id BETWEEN 2000 AND 5000;
*/

/*deduplicate however union likely did this already*/

DROP TABLE IF EXISTS Summary2;
CREATE TEMP TABLE Summary2 AS
    (
        SELECT summ,id,attachment_id
        FROM Summary
        ORDER BY summ
    )

DELETE FROM Summary2 WHERE summ is null;
DELETE FROM Summary2 WHERE summ ='' ;


/* join summary with district name */
DROP TABLE IF EXISTS sum_beats;
Create TEMP Table sum_beats as
    (
    SELECT summ,Summary2.id,district_name as district
    from Summary2
    left join sum2
    on Summary2.attachment_id = sum2.id
    )

select count(*) from Summary2;


select * from sum_beats;

Alter Table sum_beats
add hospitals int;

UPDATE sum_beats
    set hospitals=null;

UPDATE sum_beats
SET hospitals=2 where district = '2nd'

UPDATE sum_beats
SET hospitals=1 where district = '15th' or district ='18th'or district ='8th'or district ='7th'
or district ='5th' or district ='1st'or district ='3rd' or district ='14th'or district ='17th' or district ='25th'
or district ='24th'

UPDATE sum_beats
SET hospitals=3 where  district = '4th' or district ='10th' or district ='11th'or district ='16th'
or district ='18th'or district ='20th'

UPDATE sum_beats
SET hospitals=6 where district = '12th' or district = '19th'

Select * from sum_beats