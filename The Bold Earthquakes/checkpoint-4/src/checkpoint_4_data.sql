-- Get Police officer IDs for rank= Police Officer and year in [2007, 2015]
drop table if exists salaries;
create temp table salaries as (
    select officer_id, year, salary
    from data_salary
    where rank = 'Police Officer'
    and year between 2007 and 2015
);
-- select * from salaries;

-- add race and gender to this table
drop table if exists salaries_with_demographics;
create temp table salaries_with_demographics as (
    select officer_id,
           year, salary,
           race, gender,
           birth_year, date_part('year', appointed_date) as appointed_year
    from salaries
    left join data_officer
    on salaries.officer_id = data_officer.id
    order by officer_id asc
);
-- select * from salaries_with_demographics;

-- get the allegations by complaint date
-- complaint is in data_allegation.
-- officer_id is in data_allegation officer
drop table if exists allegations;
create temp table allegations as (
    with dated_allegations as (
        select data_officerallegation.officer_id as officer_id, allegation_id,
           date_part('year', date(incident_date)) as allegation_year,
           final_finding
    from data_officerallegation
    left join data_allegation
    on data_allegation.crid=data_officerallegation.allegation_id
    )
    select salaries.officer_id, salaries.year, allegation_id, final_finding
    from dated_allegations
    -- only pick officer ids that we found in salaries
    right join salaries
    on salaries.officer_id=dated_allegations.officer_id
           and salaries.year = allegation_year
    order by salaries.officer_id asc, salaries.year
);
-- select * from allegations;

-- count allegations each year
drop table if exists allegations_counts;
create temp table allegations_counts as (
    select officer_id, year,
           count(case when allegation_id is not null then 1 end) as allegations_count,
           count(case when final_finding='SU' then 1 end) as sustained_count
    from allegations
    -- where allegation_id is not null
    group by officer_id, year
    order by officer_id asc, year asc
);
-- select * from allegations_counts;

-- get awards
drop table if exists honorable_mentions;
create temp table honorable_mentions as (
    with t as (
        select officer_id as oid, award_type, date_part('year', date(start_date)) as award_year
        from data_award
             -- Look into Final, Denied, and Deleted
        where current_status != 'Denied' and award_type = 'Honorable Mention'
    )
    select salaries.officer_id, salaries.year, award_year
    from t
    right join salaries
    on t.oid = salaries.officer_id and t.award_year = salaries.year
    order by salaries.officer_id asc
);
-- select * from honorable_mentions;

-- count honorable mentions
drop table if exists hm_counts;
create temp table hm_counts as (
    select officer_id, year,
           count(case when award_year is not null then 1 end) as hm_count
    from honorable_mentions
    -- where award_year is not null
    group by officer_id, year
    order by officer_id asc, year asc
);
-- select * from hm_counts;

-- get trrs
-- create a table officer_use_of_force from trr_trr
drop table if exists trrs;
create temp table trrs as (
    with t as (
        select officer_id as oid, id as trr_id,
               date_part('year', date(trr_datetime)) as trr_year,
               taser, firearm_used,
               subject_armed, subject_injured
        from trr_trr
        )
    select salaries.officer_id, salaries.year ,
           trr_id
    from t
    right join salaries
    on salaries.officer_id = t.oid and salaries.year = t.trr_year
    order by officer_id asc, year asc
);
-- select * from trrs;

-- count trrs
drop table if exists trr_counts;
create temp table trr_counts as (
    select officer_id, year,
           count(case when trr_id is not null then 1 end) as trr_count
    from trrs
    group by officer_id, year
    order by officer_id asc, year asc
);
-- select * from trr_counts;

-- join all these tables
-- salaries_with_demographics
-- allegations_counts
-- trrs_counts
-- hm_counts
drop table if exists officer_data;
create temp table officer_data as (
    select swd.officer_id, swd.year, salary,
           race, gender, birth_year, appointed_year,
           trr_count, hm_count, allegations_count, sustained_count
    from trr_counts t
    join allegations_counts a
    on t.officer_id=a.officer_id
    and t.year=a.year
    join hm_counts h
    on a.officer_id=h.officer_id
    and  a.year=h.year
    join salaries_with_demographics swd
    on h.officer_id=swd.officer_id
    and  h.year=swd.year
    order by swd.officer_id asc, swd.year asc
);
select * from officer_data