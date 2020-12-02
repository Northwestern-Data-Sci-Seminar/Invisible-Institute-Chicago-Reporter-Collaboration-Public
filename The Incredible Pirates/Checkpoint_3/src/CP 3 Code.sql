
/*Chloropleth tables */
/* Total_injury.csv */
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
	count(case when subject_injured = 'True' then 1 end) as subject_injured,
	count(case when subject_injured = 'True' then 1 end)*100/count(*) as percent_subject_injured
from trr_trr
group by district_name
order by district_name desc;

/* Total_injury_race.csv*/
DROP TABLE IF EXISTS injury_race;
CREATE TEMP TABLE injury_race AS
    (
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
        subject_race,
        count(*) total_events,
	count(case when subject_injured = 'True' then 1 end) as subject_injured,
	count(case when subject_injured = 'True' then 1 end)*100/count(*) as percent_subject_injured
from trr_trr
group by district_name,subject_race
order by district_name desc
        );

/* total_injury_gender.csv*/
DROP TABLE IF EXISTS injury_gender;
CREATE TEMP TABLE injury_gender AS
    (

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
                   END                                                               AS district_name,
               subject_gender,
               count(*)                                                                 total_events,
               count(case when subject_injured = 'True' then 1 end)                  as subject_injured,
               count(case when subject_injured = 'True' then 1 end) * 100 / count(*) as percent_subject_injured
        from trr_trr
        group by district_name, subject_gender
        order by district_name desc
    );

delete from injury_gender where subject_gender is null;
Select * from injury_gender;

/* total_injury_age.csv*/
DROP TABLE IF EXISTS age_part1;
CREATE TEMP TABLE age_part1 AS
    (
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
               subject_age,
                count(*) total_events,
	            count(case when subject_injured = 'True' then 1 end) as subject_injured
	            /*count(case when subject_injured = 'True' then 1 end)*100/count(*) as percent_subject_injured*/
        from trr_trr
        group by district_name, subject_age
        order by district_name desc
);



DROP TABLE IF EXISTS age_part2;
CREATE TEMP TABLE age_part2 AS
    (
        SELECT CASE
                   WHEN subject_age BETWEEN 0 AND 18 THEN '0-18'
                   WHEN subject_age BETWEEN 18 AND 40 THEN '18-40'
                   WHEN subject_age BETWEEN 40 AND 65 THEN '40-65'
                   WHEN subject_age > 65 THEN '>65' END AS age_group,
               district_name,
               sum(total_events)                        as total_events,
               sum(subject_injured)                     as subject_injured,
               CAST((sum(subject_injured)  /sum(total_events) *100)  as int)        as percent_subject_injured
        from age_part1
        group by district_name, age_group
        order by district_name desc
    );


delete from age_part2 where age_group is null;
Select * from age_part2;

/* Total Injuries */
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
        0 AS acute_care_hospitals,
        count(*) total_events,
	    count(case when subject_injured = 'True' then 1 end) as subject_injured,
	    count(case when subject_injured = 'True' then 1 end)*100/count(*) as percent_subject_injured
from trr_trr
group by district_name
order by district_name desc;

/*Districts_HCG_general_acute_care_hopsital*/
DROP TABLE IF EXISTS Districts_HCG_general_acute_care_hopsital;
CREATE TEMP TABLE Districts_HCG_general_acute_care_hopsital AS
    (
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
                   END                                                               AS district_name,
               0                                                                     AS acute_care_hospitals,
               count(*)                                                                 total_events,
               count(case when subject_injured = 'True' then 1 end)                  as subject_injured,
               count(case when subject_injured = 'True' then 1 end) * 100 / count(*) as percent_subject_injured
        from trr_trr
        group by district_name
        order by district_name desc
    );

UPDATE Districts_HCG_general_acute_care_hopsital
SET acute_care_hospitals=2 where district_name = '2nd'

UPDATE Districts_HCG_general_acute_care_hopsital
SET acute_care_hospitals=1 where district_name = '15th' or district_name ='18th'or district_name ='8th'or district_name ='7th'
or district_name ='5th' or district_name ='1st'or district_name ='3rd' or district_name ='14th'or district_name ='17th' or district_name ='25th'
or district_name ='24th'

UPDATE Districts_HCG_general_acute_care_hopsital
SET acute_care_hospitals=3 where  district_name = '4th' or district_name ='10th' or district_name ='11th'or district_name ='16th'
or district_name ='18th'or district_name ='20th'

UPDATE Districts_HCG_general_acute_care_hopsital
SET acute_care_hospitals=6 where district_name = '12th' or district_name = '19th'

Select * from Districts_HCG_general_acute_care_hopsital


/*weapon type data */
DROP TABLE IF EXISTS weapon_plot2;
 CREATE TEMP TABLE weapon_plot2 AS
     (
         SELECT subject_race, member_action, force_type,subject_injured, subject_alleged_injury
         FROM trr_trr
         LEFT JOIN trr_actionresponse tw on  trr_trr.id =  tw.trr_id
     );

DROP TABLE IF EXISTS weapon_race_injury2;
 CREATE TEMP TABLE weapon_race_injury2 AS
     (
         SELECT subject_race,
                CASE
                    WHEN force_type = 'Firearm' THEN 'Firearm'
                    WHEN force_type = 'Taser' or force_type = 'Impact Weapon' THEN 'Taser/Impact Weapon'
                    WHEN force_type = 'CHEMICAL'or force_type = 'Chemical (Authorized)' THEN 'Chemical'
                    WHEN force_type = 'OTHER' or force_type = 'Other Force' THEN 'Other'
                    WHEN force_type = 'Member Presence' THEN 'Member Presence'
                    WHEN force_type = 'Physical Force - Direct Mechanical' or force_type = 'Physical Force - Stunning' or force_type = 'Physical Force - Holding' THEN 'Physical Force'
                    when force_type = 'Verbal Commands' THEN 'Verbal Commands'
                    END  AS Weapon_used,
                CASE
                    WHEN subject_alleged_injury = 'true' and subject_injured = 'false' then 'Injured'
                    when subject_injured = 'true' then 'Injured'
                    when subject_injured = 'false' and subject_alleged_injury = 'false' then 'Uninjured'
                    when subject_injured is null or subject_alleged_injury is null then 'Uninjured'
                    END  AS Alleged_or_Injured,
                CASE
                    WHEN subject_alleged_injury = 'true' and subject_injured = 'false' then 'Alleged_Injury'
                    when subject_injured = 'true' then 'Officer_Supported_Injury'
                    when subject_injured = 'false' and subject_alleged_injury = 'false' then null
                    when subject_injured is null or subject_alleged_injury is null then null
                    END  AS Injury_documentation,
                count(*) AS total_use_of_force_events
         FROM weapon_plot2
         GROUP BY subject_race, Weapon_used, Alleged_or_Injured, Injury_documentation
         ORDER BY subject_race
 );


 delete from Weapon_race_injury2 where subject_race is null
 Select * from Weapon_race_injury2


