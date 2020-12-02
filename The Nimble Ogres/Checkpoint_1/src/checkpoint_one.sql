-- question 1
SELECT avg(lawsuit_lawsuit.total_payments) as average_payments, trr_trr.subject_race as race_of_victim, count(trr_trr.subject_race) as no_of_cases FROM lawsuit_lawsuit
INNER JOIN lawsuit_lawsuit_officers llo ON lawsuit_lawsuit.id = llo.lawsuit_id
INNER JOIN data_officer ON llo.officer_id = data_officer.id
INNER JOIN trr_trr ON trr_trr.officer_id = data_officer.id AND DATE(trr_trr.trr_datetime) = DATE(lawsuit_lawsuit.incident_date)
GROUP BY trr_trr.subject_race
ORDER BY average_payments desc;

-- question 2
SELECT
        count(CASE WHEN misconducts::text LIKE '%False arrest%' THEN 1 END) AS False_arrest_or_report,
        count(CASE WHEN misconducts::text LIKE '%Sexual harassment%' THEN 1 END) AS Sexual_harrassment_abuse,
        count(CASE WHEN misconducts::text LIKE '%Destroy%' THEN 1 END) AS Destroy_conceal_fabricate_evidence,
        count(CASE WHEN misconducts::text LIKE '%Witness%' THEN 1 END) AS Witness_manipulation,
        count(CASE WHEN misconducts::text LIKE '%Threats%' THEN 1 END) AS Threats_or_intimidation,
        count(CASE WHEN misconducts::text LIKE '%Damage%' THEN 1 END) AS Damage_to_property,
        count(CASE WHEN misconducts::text LIKE '%Shooting%' THEN 1 END) AS Shooting,
        count(CASE WHEN misconducts::text LIKE '%Stolen%' THEN 1 END) AS Stolen_property,
        count(CASE WHEN misconducts::text LIKE '%Illegal search%' THEN 1 END) AS Illegal_search_seizure,
        count(CASE WHEN misconducts::text LIKE '%Pattern%' THEN 1 END) AS Pattern_of_misconduct,
        count(CASE WHEN misconducts::text LIKE '%Legal%' THEN 1 END) AS Legal_access_denied,
        count(CASE WHEN misconducts::text LIKE '%Failure%' THEN 1 END) AS Failure_to_provide_medical_care,
        count(CASE WHEN misconducts::text LIKE '%Racial%' THEN 1 END) AS Racial_epithets,
        count(CASE WHEN misconducts::text LIKE '%Strip%' THEN 1 END) AS Strip_search,
        count(CASE WHEN misconducts::text LIKE '%Torture%' THEN 1 END) AS Torture,
        count(CASE WHEN misconducts::text LIKE '%Forced%' THEN 1 END) AS Forced_confession,
        count(CASE WHEN misconducts::text LIKE '%Retaliation%' THEN 1 END) AS Retaliation,
        count(CASE WHEN misconducts::text LIKE 'Bribery%%' THEN 1 END) AS Bribery
FROM lawsuit_lawsuit;

-- most common allegation category in allegations
select distinct category, allegation_name, count(data_allegation.crid) as alleg_count from data_allegationcategory
inner join data_officerallegation on data_officerallegation.allegation_category_id = data_allegationcategory.id
inner join data_allegation on data_allegation.crid = data_officerallegation.allegation_id
group by category, allegation_name
order by alleg_count desc;

-- question 3
WITH race_matrix AS (
select data_victim.race as victim_race, data_officer.race as police_race, count(*) as alleg_count from data_officerallegation
inner join data_officer on data_officer.id = data_officerallegation.officer_id
inner join data_allegation on data_officerallegation.allegation_id = data_allegation.crid
inner join data_victim on data_allegation.crid = data_victim.allegation_id
group by victim_race, police_race
order by alleg_count desc),
race_matrix2 AS (
select data_victim.race as victim_race, data_officer.race as police_race, count(*) as sustained_alleg_count from data_officerallegation
inner join data_officer on data_officer.id = data_officerallegation.officer_id
inner join data_allegation on data_officerallegation.allegation_id = data_allegation.crid
inner join data_victim on data_allegation.crid = data_victim.allegation_id
where final_finding = 'SU'
group by victim_race, police_race
order by sustained_alleg_count desc)

SELECT race_matrix.police_race, race_matrix.victim_race, alleg_count, sustained_alleg_count, sustained_alleg_count/CAST(alleg_count as float) * 100 as percent
FROM race_matrix
inner join race_matrix2 on race_matrix.police_race = race_matrix2.police_race and race_matrix.victim_race = race_matrix2.victim_race
where race_matrix.victim_race != ''
order by percent desc;

-- question 4
WITH race_matrix AS (
select data_investigator.race as investigator_race, data_officer.race as police_race, count(*) as alleg_count from data_officerallegation
inner join data_officer on data_officer.id = data_officerallegation.officer_id
inner join data_allegation on data_officerallegation.allegation_id = data_allegation.crid
inner join data_investigatorallegation on data_investigatorallegation.allegation_id = data_allegation.crid
inner join data_investigator on data_investigatorallegation.investigator_id = data_investigator.id
group by investigator_race, police_race
order by alleg_count desc),
race_matrix2 AS (
select data_investigator.race as investigator_race, data_officer.race as police_race, count(*) as sustained_alleg_count from data_officerallegation
inner join data_officer on data_officer.id = data_officerallegation.officer_id
inner join data_allegation on data_officerallegation.allegation_id = data_allegation.crid
inner join data_investigatorallegation on data_investigatorallegation.allegation_id = data_allegation.crid
inner join data_investigator on data_investigatorallegation.investigator_id = data_investigator.id
where final_finding = 'SU'
group by investigator_race, police_race
order by sustained_alleg_count desc)

SELECT race_matrix.police_race, race_matrix.investigator_race, alleg_count, sustained_alleg_count, sustained_alleg_count/CAST(alleg_count as float) * 100 as percent
FROM race_matrix
inner join race_matrix2 on race_matrix.police_race = race_matrix2.police_race and race_matrix.investigator_race = race_matrix2.investigator_race
where race_matrix.investigator_race != ''
order by percent desc;


