-- UNITS
-- UNITS
-- UNITS
drop table if exists officer_units_dated;
create temp table officer_units_dated as (
    select officer_id,
           unit_id, unit_name, description as unit_description,
           date(effective_date) as min_date,
           coalesce(end_date, cast('2100-01-01' as date)) as max_date
    from data_officerhistory
    left join data_policeunit
    on data_officerhistory.unit_id = data_policeunit.id
    where unit_id > 1 and unit_id < 27
);
-- select * from officer_units_dated;

-- create a table officer units
-- officer_id, unit_id, year, where unit_id in (1, 26)
drop table if exists unit_counts;
create temp table unit_counts as (
    with units as (
        select officer_id,
               unit_id, unit_name, unit_description,
               min_date, max_date
        from officer_units_dated
    )
    select date_part('year', min_date) as year,
           unit_id, unit_name,
           count(distinct officer_id) as unit_size_that_year
    from units
    group by unit_id, unit_name, year
    order by year desc, unit_id asc
);
-- select * from unit_counts;

-- ALLEGATIONS
-- ALLEGATIONS
-- ALLEGATIONS

-- create a table officer_allegations_dated from data_officerallegation
-- officer_id, allegation_id, final_finding, allegation_date
drop table if exists officer_allegations_dated;
create temp table officer_allegations_dated as (
    select id, officer_id, allegation_id as complaint_id,
           date(incident_date) as complaint_date,
           final_finding, final_outcome, disciplined
    from data_officerallegation
    left join data_allegation
    on data_allegation.crid=data_officerallegation.allegation_id
);
-- select * from officer_allegations_dated;

-- unify units and allegations
drop table if exists officer_allegations_units;
create temp table officer_allegations_units as (
    select id, officer_allegations_dated.officer_id as officer_id,
           complaint_id, complaint_date,
           date_part('year', complaint_date) as event_year,
           final_finding, final_outcome, disciplined,
           unit_id, unit_name, unit_description
    from officer_allegations_dated
    left join officer_units_dated
    on officer_allegations_dated.officer_id=officer_units_dated.officer_id
    and (officer_allegations_dated.complaint_date
        between officer_units_dated.min_date
        and officer_units_dated.max_date
    )
);
-- select * from officer_allegations_units;

-- unify allegations and units with units counts
drop table if exists allegations_units;
create temp table allegations_units as (
    select id, officer_id, complaint_id, complaint_date, event_year,
           final_finding, final_outcome, disciplined,
           officer_allegations_units.unit_id as unit_id,
           officer_allegations_units.unit_name as unit_name,
           unit_description, unit_size_that_year
    from officer_allegations_units
    left join unit_counts
    on unit_counts.unit_id=officer_allegations_units.unit_id
    and unit_counts.year=officer_allegations_units.event_year
);
-- select * from allegations_units;

-- group allegation units by unit by year
-- add count of allegations
-- add count of sustained allegations
drop table if exists allegations_units_counts;
create temp table allegations_units_counts as (
    with allegations as (
        select id, officer_id,
           complaint_id, complaint_date, event_year,
           final_finding, final_outcome, disciplined,
           unit_id, unit_name, unit_description, unit_size_that_year
        from allegations_units
    )
    select unit_id, unit_name, unit_description, unit_size_that_year,
           event_year as year,
           count(distinct id) as allegation_count,
           count(case when final_finding = 'SU' then 1 else null end) as sustained_allegation_count
    from allegations
    group by unit_id, unit_name, unit_description, unit_size_that_year,
             year
    order by unit_id asc, year desc
);
-- select * from allegations_units_counts;

-- aggregate allegations and unit sizes over years 2007-2015
drop table if exists aggregate_allegations;
create temp table aggregate_allegations as (
    select unit_name,
           sum(unit_size_that_year) as unit_size,
           sum(allegation_count) as total_allegations,
           sum(sustained_allegation_count) as total_sustained_allegations
    from allegations_units_counts
    where year > 2006 and year < 2016
    group by unit_name
);
-- select * from aggregate_allegations

-- AWARDS
-- AWARDS
-- AWARDS

-- create a table officer awards that is properly dated
drop table if exists officer_awards_dated;
create temp table officer_awards_dated as (
    select officer_id, award_type, date(start_date) as award_date, rank
    from data_award
    -- Look into Final, Denied, and Deleted
    where current_status != 'Denied' and rank like '%Police Officer'
);
-- select * from officer_awards_dated;

-- unify units and awards
drop table if exists officer_awards_units;
create temp table officer_awards_units as (
    select officer_awards_dated.officer_id as officer_id, rank, award_type, award_date,
           date_part('year', award_date) as event_year,
           unit_id, unit_name, unit_description
    from officer_awards_dated
    left join officer_units_dated
    on officer_awards_dated.officer_id=officer_units_dated.officer_id
    and (officer_awards_dated.award_date
        between officer_units_dated.min_date
        and officer_units_dated.max_date
        )
);
-- select * from officer_awards_units;

-- unify awards units and unit counts
-- unify allegations and units with units counts
drop table if exists awards_units;
create temp table awards_units as (
    select officer_id, rank,
           award_type, award_date, event_year,
           officer_awards_units.unit_id as unit_id,
           officer_awards_units.unit_name as unit_name,
           unit_description, unit_size_that_year
    from officer_awards_units
    left join unit_counts
    on unit_counts.unit_id=officer_awards_units.unit_id
    and unit_counts.year=officer_awards_units.event_year
);
-- select * from awards_units;

-- group awards units by unit by year
-- add count of awards
drop table if exists awards_units_counts;
create temp table awards_units_counts as (
    select unit_id, unit_name, unit_description, unit_size_that_year,
           event_year as year,
           count(*) as awards_count
    from awards_units
    group by unit_id, unit_name, unit_description, unit_size_that_year,
             year
    order by unit_id asc, year desc
);
-- select * from awards_units_counts;

-- aggregate awards and unit sizes over years 2007-2015
drop table if exists aggregate_awards;
create temp table aggregate_awards as (
    select unit_name,
           sum(unit_size_that_year) as unit_size,
           sum(awards_count) as total_awards
    from awards_units_counts
    where year > 2006 and year < 2016
    group by unit_name
);
-- select * from aggregate_awards

-- TRRS
-- TRRS
-- TRRS

-- create a table officer_use_of_force from trr_trr
drop table if exists officer_trrs_dated;
create temp table officer_trrs_dated as (
    select officer_id,
           id as trr_id,
           date(trr_datetime) as trr_date,
           officer_unit_id as trr_unit_id,
           taser, firearm_used,
           subject_armed, subject_injured
    from trr_trr
    where officer_rank = 'Police Officer'
);
select * from officer_trrs_dated;

-- unify units and officer_trr_dated
drop table if exists officer_trrs_units;
create temp table officer_trrs_units as (
    select officer_trrs_dated.officer_id as officer_id,
           trr_id, trr_unit_id, trr_date,
           date_part('year', trr_date) as event_year,
           taser, firearm_used, subject_armed, subject_injured,
           unit_id, unit_name, unit_description
    from officer_trrs_dated
    left join officer_units_dated
    on officer_trrs_dated.officer_id=officer_units_dated.officer_id
    and (
        officer_trrs_dated.trr_date
        between officer_units_dated.min_date
        and officer_units_dated.max_date
        )
    where trr_unit_id > 1 and trr_unit_id < 27
);
-- select * from officer_trrs_units;

-- unify awards units and unit counts
-- unify allegations and units with units counts
drop table if exists trrs_units;
create temp table trrs_units as (
    select officer_id,
           trr_id, trr_unit_id,
           trr_date, event_year,
           taser, firearm_used, subject_armed, subject_injured,
           officer_trrs_units.unit_id as unit_id,
           officer_trrs_units.unit_name as unit_name,
           unit_description, unit_size_that_year
    from officer_trrs_units
    left join unit_counts
    on unit_counts.unit_id=officer_trrs_units.unit_id
    and unit_counts.year=officer_trrs_units.event_year
);
-- select * from trrs_units;

drop table if exists trrs_units_counts;
create temp table trrs_units_counts as (
    select unit_id, unit_name, unit_description, unit_size_that_year,
           event_year as year,
           count(distinct trr_id) as trr_count,
           count(case when taser = True then 1 else null end) as taser_count,
           count(case when firearm_used = True then 1 else null end) as firearm_count,
           count(case when subject_injured = True then 1 else null end) as subject_injured_count,
           count(case when subject_armed = True then 1 else null end) as subject_armed_count
    from trrs_units
    group by unit_id, unit_name, unit_description, unit_size_that_year,
             year
    order by unit_id asc, year desc
);
-- select * from trrs_units_counts;

-- aggregate trrs and unit sizes over years 2007-2015
drop table if exists aggregate_trrs;
create temp table aggregate_trrs as (
    select unit_name,
           sum(unit_size_that_year) as unit_size,
           sum(trr_count) as total_trrs
    from trrs_units_counts
    where year > 2006 and year < 2016
    group by unit_name
);
-- select * from aggregated_trrs

-- aggregate trrs and unit sizes over years 2007-2015
drop table if exists aggregation;
create temp table aggregation as (
    select aggregate_allegations.unit_name,
           round(total_allegations/aggregate_allegations.unit_size, 3) as allegations_per_capita,
           round(total_sustained_allegations/aggregate_allegations.unit_size, 3) as sustained_allegations_per_capita,
           round(total_trrs/aggregate_allegations.unit_size, 3) as trrs_per_capita,
           round(total_awards/aggregate_allegations.unit_size, 3) as awards_per_capita
    from aggregate_allegations
    left join aggregate_awards
    on aggregate_allegations.unit_name=aggregate_awards.unit_name
    left join aggregate_trrs
    on aggregate_allegations.unit_name=aggregate_trrs.unit_name
    where aggregate_allegations.unit_name is not null
);
select * from aggregation