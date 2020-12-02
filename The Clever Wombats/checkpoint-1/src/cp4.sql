drop table if exists finding_per_beat_year;
create temp table finding_per_beat_year as (
select a.year, a.beat_id, da.final_finding, da.officer_id, da.allegation_id as alleg_id
from data_officerallegation as da
inner join (select crid, beat_id, extract(year from incident_date) as year
from data_allegation) a
on a.crid = da.allegation_id);

select * from finding_per_beat_year;

drop table if exists added_officer_bio;
create temp table added_officer_bio as (
    select t1.year, t1.beat_id, t1.officer_id, t2.gender, t2.race, t1.alleg_id, t1.final_finding
    from finding_per_beat_year t1
    inner join (select gender, race, id
        from data_officer) t2
    on t1.officer_id = t2.id
);
select * from added_officer_bio;

drop table if exists added_complainant_bio;
create temp table added_complainant_bio as (
    select t1.year, t1.beat_id, t1.alleg_id, t1.gender as officer_gender, t1.race as officer_race, t2.gender as complainent_gender, t2.race as complainent_race, t1.final_finding
    from added_officer_bio t1
    inner join (select gender, race, allegation_id
        from data_complainant) t2
    on t1.alleg_id = t2.allegation_id
);

drop table if exists removed_nulls;
create temp table removed_nulls as (
    select *
    from added_complainant_bio
    where year is not null
      and beat_id is not null
      and alleg_id is not null
      and officer_gender is not null
      and officer_race is not null
      and complainent_gender is not null
      and complainent_race is not null
      and final_finding is not null
);

drop table if exists updated_gender_finding;
create temp table updated_gender_finding as (
    select *
    from removed_nulls
    where (final_finding = 'NS' or final_finding = 'SU')
      and (complainent_gender = 'M' or complainent_gender = 'F')
      and (officer_gender = 'M' or officer_gender = 'F')
);

UPDATE updated_gender_finding
SET officer_race = TRIM(officer_RACE),
    officer_gender = TRIM(officer_gender),
    complainent_race = TRIM(complainent_race),
    complainent_gender = TRIM(complainent_gender)

select * from updated_gender_finding
where not officer_race='' and not complainent_race='';



