DROP TABLE IF EXISTS cp3_1_a;
CREATE TEMP TABLE cp3_1_a AS
    (
        SELECT trr_trr.id, subject_injured,subject_alleged_injury,beat,lighting_condition,indoor_or_outdoor,weather_condition,officer_in_uniform,
               officer_injured,officer_rank,subject_armed,subject_age,subject_gender,subject_race,officer_id,dof.gender,dof.race,
               dof.birth_year,trr_datetime
        FROM trr_trr
        LEFT JOIN data_officer dof on  trr_trr.officer_id = dof.id
    );

Select count(*) from cp3_1_a;

DROP TABLE IF EXISTS cp3_1_fire;
CREATE TEMP TABLE cp3_1_fire AS
    (
        SELECT trr_id,
               count(CASE WHEN force_type = 'Firearm' THEN 1 end) AS wep_firearm,
               count(CASE WHEN force_type = 'Taser' or force_type = 'Impact Weapon' THEN 1 end) AS wep_taser,
               count(Case WHEN force_type = 'CHEMICAL'or force_type = 'Chemical (Authorized)' THEN 1 end) as wep_chemical,
               count(case WHEN force_type = 'OTHER' or force_type = 'Other Force' THEN 1 end)as wep_other,
               count(case WHEN force_type = 'Member Presence' THEN 1  end) as wep_member,
               count(case When force_type = 'Physical Force - Direct Mechanical' or force_type = 'Physical Force - Stunning' or force_type = 'Physical Force - Holding' THEN 1 end) as wep_phys,
               count(case when  force_type = 'Verbal Commands' THEN 1 end) as wep_verb
        FROM trr_actionresponse
        GROUP BY trr_id
        ORDER BY trr_id

    );

UPDATE cp3_1_fire SET wep_firearm = 1 WHERE wep_firearm > 1;
UPDATE cp3_1_fire SET wep_taser = 1 WHERE wep_taser > 1;
UPDATE cp3_1_fire SET wep_chemical = 1 WHERE wep_chemical > 1;
UPDATE cp3_1_fire SET wep_other = 1 WHERE wep_other > 1;
UPDATE cp3_1_fire SET wep_member = 1 WHERE wep_member > 1;
UPDATE cp3_1_fire SET wep_phys = 1 WHERE wep_phys > 1;
UPDATE cp3_1_fire SET wep_verb = 1 WHERE wep_verb > 1;



DROP TABLE IF EXISTS cp3_1_c;
CREATE TEMP TABLE cp3_1_c AS
    (
        SELECT id, subject_injured,subject_alleged_injury,beat,lighting_condition,indoor_or_outdoor,weather_condition,officer_in_uniform,
               officer_injured,officer_rank,subject_armed,subject_age,subject_gender,subject_race,officer_id,gender,race,birth_year,extract(year from trr_datetime) as trr_year, wep_firearm
             ,wep_taser,wep_chemical,wep_other,wep_member,wep_phys,wep_verb

        FROM cp3_1_a
        LEFT JOIN cp3_1_fire on  cp3_1_a.id = cp3_1_fire.trr_id
    );






DROP TABLE IF EXISTS cp3_1_d;
CREATE TEMP TABLE cp3_1_d AS
    (
        SELECT id, lighting_condition,indoor_or_outdoor,weather_condition,officer_in_uniform,
               officer_injured,officer_rank,subject_armed,subject_age,subject_gender,subject_race,officer_id,gender as officer_gender,
               race as officer_race, CAST(trr_year as int) - CAST(birth_year as int) as officer_age,
               wep_taser,wep_chemical,wep_other,wep_member,wep_phys,wep_verb,wep_firearm,
               CASE
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
                   case when subject_injured = 'True' or subject_alleged_injury= 'True' then 1 end  as injury
        FROM cp3_1_c
        GROUP BY id,lighting_condition,indoor_or_outdoor,weather_condition,officer_in_uniform,
               officer_injured,officer_rank,subject_armed,subject_age,subject_gender,subject_race,officer_id,gender,race, officer_age, district_name
                  ,wep_taser,wep_chemical,wep_other,wep_member,wep_phys,wep_verb, wep_firearm, injury
    );

UPDATE cp3_1_d SET injury = 0 WHERE injury is null;



select * from cp3_1_d;


