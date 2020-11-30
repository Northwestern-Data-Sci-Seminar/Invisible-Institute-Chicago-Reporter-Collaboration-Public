drop table if exists vandyke;
create temp table vandyke as (
    select *
    from data_officer
    where last_name='Van Dyke'
);
-- select * from vandyke;

drop table if exists district_nine_ids;
create temp table district_nine_ids as (
    select officer_id
    from data_officerhistory
    where unit_id=10 and date_part('year', effective_date)=2002
);
-- select * from district_nine_ids;

drop table if exists district_nine_officers;
create table district_nine_officers as (
    select *
    from data_officer
    right join district_nine_ids
    on officer_id=id
    where has_unique_name=true
    and gender = 'M'
    and race = 'White'
    and date_part('year', appointed_date)=2001
    and rank='Police Officer'
    and birth_year between 1972 and 1978
);
-- select * from district_nine_officers;

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
-- select * from officer_trrs_dated;

-- create a table officer awards that is properly dated
drop table if exists officer_awards_dated;
create temp table officer_awards_dated as (
    select officer_id, award_type, date(start_date) as award_date, rank
    from data_award
    -- Look into Final, Denied, and Deleted
    where current_status != 'Denied' and rank like '%Police Officer'
);
-- select * from officer_awards_dated;

-- unify these for district nein
drop table if exists district_nine_careers;
create temp table district_nine_careers as (
    select district_nine_officers.officer_id, appointed_date, resignation_date,
           complaint_date, final_finding, final_outcome, disciplined,
           trr_date, taser, firearm_used, subject_armed, subject_injured,
           award_type, award_date
    from district_nine_officers
    left outer join officer_allegations_dated
    on district_nine_officers.officer_id=officer_allegations_dated.officer_id
    left outer join officer_awards_dated
    on district_nine_officers.officer_id=officer_awards_dated.officer_id
    left outer join officer_trrs_dated
    on district_nine_officers.officer_id=officer_trrs_dated.officer_id
);
-- select * from district_nine_careers;

drop table if exists district_nine_trrs;
create temp table district_nine_trrs as (
    select district_nine_officers.officer_id, trr_date
    from district_nine_officers
    left join officer_trrs_dated
    on district_nine_officers.officer_id=officer_trrs_dated.officer_id
);
-- select * from district_nine_trrs

drop table if exists district_nine_allegations;
create temp table district_nine_allegations as (
    select district_nine_officers.officer_id, complaint_date
    from district_nine_officers
    left join officer_allegations_dated
    on district_nine_officers.officer_id=officer_allegations_dated.officer_id
);
-- select * from district_nine_allegations;

drop table if exists district_nine_awards;
create temp table district_nine_awards as (
    select district_nine_officers.officer_id, award_date
    from district_nine_officers
    left join officer_awards_dated
    on district_nine_officers.officer_id=officer_awards_dated.officer_id
);

drop table if exists dates;
create temp table dates as (
    select district_nine_allegations.officer_id as allegations_oid,
           district_nine_awards.officer_id as awards_oid,
           award_date, complaint_date
    from district_nine_allegations
    full outer join district_nine_awards
    on district_nine_allegations.complaint_date=district_nine_awards.award_date
);
-- select * from dates;

-- create timelines
drop table if exists timelines;
create temp table timelines as (
    with t as (
        select coalesce(allegations_oid, awards_oid) as officer_id,
               allegations_oid, awards_oid,
               coalesce(award_date, complaint_date) as event_date,
               award_date, complaint_date
        from dates
    )
    select officer_id,
           event_date,
           (case when award_date is null then false else true end) as award,
           (case when complaint_date is null then false else true end) as complaint
    from t
    order by officer_id, event_date
);
select * from timelines