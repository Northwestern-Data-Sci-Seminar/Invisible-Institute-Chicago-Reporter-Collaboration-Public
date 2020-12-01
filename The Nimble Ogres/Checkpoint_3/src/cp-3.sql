-- Produces the outline of chicago with the population data for each area.
-- This is used for both of the questions to map a projection of Chicago.

SELECT row_to_json(fc) as data_geometry
FROM (SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
      FROM (SELECT 'Feature' As type
                 , ST_AsGeoJSON(area.polygon)::json As geometry
                 , row_to_json((SELECT l
                                FROM (SELECT area.id,
                                             sum(dr.count) as total_pop,
                                             dr.race) As l
                 )) As properties
                 from data_area area
                 inner join data_racepopulation dr on area.id = dr.area_id
                 group by area.id, area.polygon, dr.race, dr.count) As f) As fc;


-- Question 1

-- Data for Number of Allegation for each race according to an area:

select daa.area_id, count(*) as num_alleg, dv.race as race from data_allegation
inner join data_allegation_areas daa on data_allegation.crid = daa.allegation_id
inner join data_victim dv on data_allegation.crid = dv.allegation_id
group by daa.area_id, dv.race
order by daa.area_id desc;

-- Data for total number of Allegation for each area:

select daa.area_id, count(*) as num_alleg from data_allegation
inner join data_allegation_areas daa on data_allegation.crid = daa.allegation_id
inner join data_victim dv on data_allegation.crid = dv.allegation_id
group by daa.area_id
order by daa.area_id desc;



-- Question 2

-- Data for the allegations for each police officer according to
-- the area and the race of the officer

SELECT DAA.area_id, EXTRACT(YEAR FROM CAST(ALLEGATIONS.incident_date AS DATE)) AS ALLEG_YEAR, DOF.race AS OFFICER_RACE, count(*)
FROM data_allegation AS ALLEGATIONS
INNER JOIN data_allegation_areas DAA ON ALLEGATIONS.crid = DAA.allegation_id
INNER JOIN data_officerallegation DOA ON ALLEGATIONS.crid = DOA.allegation_id
INNER JOIN data_officer DOF ON DOA.officer_id = DOF.id
GROUP BY EXTRACT(YEAR FROM CAST(ALLEGATIONS.incident_date AS DATE)), DOF.race, DAA.area_id
ORDER BY DAA.area_id;

-- Shift duty data for White Officers according to the area and the year

Drop TABLE IF EXISTS tb1_white;

-- Step 1: Create a Temp Table
Create TEMP TABLE tb1_white As
select DOAA.officer_id, doaa.race, EXTRACT(YEAR FROM CAST(doaa.shift_start AS DATE)) as year from data_officerassignmentattendance as doaa
inner join data_officer d on d.id = doaa.officer_id
where doaa.race = 'White' and EXTRACT(YEAR FROM CAST(doaa.shift_start AS DATE)) is not null
group by DOAA.officer_id, doaa.race, EXTRACT(YEAR FROM CAST(doaa.shift_start AS DATE));

-- Step 2: Final Result (Export to CSV)
select daa.area_id, doaa.year, count(*) from tb1_white as doaa
inner join data_officer d on d.id = doaa.officer_id
inner join data_officerallegation doa on d.id = doa.officer_id
inner join data_allegation_areas daa on doa.allegation_id = daa.allegation_id
group by doaa.year, daa.area_id
order by doaa.year desc;


-- Shift duty data for Black Officers according to the area and the year

Drop TABLE IF EXISTS tb1_black;

-- Step 1: Create a Temp Table
Create TEMP TABLE tb1_black As
select DOAA.officer_id, doaa.race, EXTRACT(YEAR FROM CAST(doaa.shift_start AS DATE)) as year from data_officerassignmentattendance as doaa
inner join data_officer d on d.id = doaa.officer_id
where doaa.race = 'Black' and EXTRACT(YEAR FROM CAST(doaa.shift_start AS DATE)) is not null
group by DOAA.officer_id, doaa.race, EXTRACT(YEAR FROM CAST(doaa.shift_start AS DATE));

-- Step 2: Final Result (Export to CSV)
select daa.area_id, doaa.year, count(*) from tb1_black as doaa
inner join data_officer d on d.id = doaa.officer_id
inner join data_officerallegation doa on d.id = doa.officer_id
inner join data_allegation_areas daa on doa.allegation_id = daa.allegation_id
group by doaa.year, daa.area_id
order by doaa.year desc;


-- Shift duty data for Hispanic Officers according to the area and the year
Drop TABLE IF EXISTS tb1_hisp;

-- Step 1: Create a Temp Table
Create TEMP TABLE tb1_hisp As
select DOAA.officer_id, doaa.race, EXTRACT(YEAR FROM CAST(doaa.shift_start AS DATE)) as year from data_officerassignmentattendance as doaa
inner join data_officer d on d.id = doaa.officer_id
where doaa.race = 'Hispanic' and EXTRACT(YEAR FROM CAST(doaa.shift_start AS DATE)) is not null
group by DOAA.officer_id, doaa.race, EXTRACT(YEAR FROM CAST(doaa.shift_start AS DATE));

-- Step 2: Final Result (Export to CSV)
select daa.area_id, doaa.year, count(*) from tb1_hisp as doaa
inner join data_officer d on d.id = doaa.officer_id
inner join data_officerallegation doa on d.id = doa.officer_id
inner join data_allegation_areas daa on doa.allegation_id = daa.allegation_id
group by doaa.year, daa.area_id
order by doaa.year desc;

-- Shift duty data for Asian Officers according to the area and the year
Drop TABLE IF EXISTS tb1_asian;

-- Step 1: Create a Temp Table
Create TEMP TABLE tb1_asian As
select DOAA.officer_id, doaa.race, EXTRACT(YEAR FROM CAST(doaa.shift_start AS DATE)) as year from data_officerassignmentattendance as doaa
inner join data_officer d on d.id = doaa.officer_id
where doaa.race = 'Asian/Pacific Islander' and EXTRACT(YEAR FROM CAST(doaa.shift_start AS DATE)) is not null
group by DOAA.officer_id, doaa.race, EXTRACT(YEAR FROM CAST(doaa.shift_start AS DATE));

-- Step 2: Final Result (Export to CSV)
select daa.area_id, doaa.year, count(*) from tb1_asian as doaa
inner join data_officer d on d.id = doaa.officer_id
inner join data_officerallegation doa on d.id = doa.officer_id
inner join data_allegation_areas daa on doa.allegation_id = daa.allegation_id
group by doaa.year, daa.area_id
order by doaa.year desc;