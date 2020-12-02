-- Get Police officer IDs for rank= Police Officer and year in [2007, 2015]
drop table if exists officers_2007_2015;
create temp table officers_2007_2015 as (
    select officer_id, year, salary
    from data_salary
    where rank = 'Police Officer'
    and year between 2007 and 2015
);
-- select * from officers_2007_2015;

-- get officer IDs for which there is a salary in each year (9 year period)
drop table if exists full_activity;
create temp table full_activity as (
    with c as (
        select count(distinct year) as years_active, officer_id
        from officers_2007_2015
        group by officer_id
    )
    select officer_id, years_active from c
    where years_active=9
);
-- select * from full_activity;

-- USE FULL ACTIVITY, A LIST OF OFFICER ID's TO FILTER THE officers_2007-2015 table
drop table if exists active_officers;
create temp table active_officers as (
    select officers_2007_2015.officer_id as officer_id,
           year, salary
    from full_activity
    left join officers_2007_2015
    on officers_2007_2015.officer_id=full_activity.officer_id
);
-- select * from active_officers;

-- add race and gender to this table
drop table if exists active_officers_dem;
create temp table active_officers_dem as (
    select officer_id,
           year, salary,
           race, gender
    from active_officers
    left join data_officer
    on active_officers.officer_id = data_officer.id
    where year=2007 or year=2015
    order by officer_id asc
);
-- select * from active_officers_dem;

-- add race and gender to this table
drop table if exists salaries;
create temp table salaries as (
    with t as (
        select officer_id,
               race,
               gender,
               (case when year = 2007 then salary end) as start_salary,
               (case when year = 2015 then salary end) as end_salary
        from active_officers_dem
    )
    select officer_id, race, gender,
           max(start_salary) as start_salary,
           max(end_salary) as end_salary
    from t
    group by officer_id, race, gender
    order by officer_id asc
);
-- select * from salaries;

-- get the allegations by complaint date
-- complaint is in data_allegation.
-- officer_id is in data_allegation officer
drop table if exists allegations;
create temp table allegations as (
    select data_officerallegation.officer_id as officer_id, allegation_id,
           date(incident_date) as date,
           final_finding
    from data_officerallegation
    left join data_allegation
    on data_allegation.crid=data_officerallegation.allegation_id
    -- only pick officer ids that we found in salaries
    right join salaries
    on salaries.officer_id=data_officerallegation.officer_id
    order by officer_id asc, date asc
);
-- select * from allegations;

-- add counts to allegations for each year
drop table if exists count_allegations_year;
create temp table count_allegations_year as (
    -- we remove rows for allegations after 2015
    with allegations_until_2015 as (
        select officer_id, allegation_id, date_part('year', date) as year, final_finding
        from allegations
        where date_part('year', date) < 2016
    )
    select A.officer_id,A.year,
           -- number of allegations by the end of each year
           (SELECT count(B.*)
           from allegations_until_2015 B
           where B.year<= A.year and B.officer_id = A.officer_id) as allegation_count,
           -- number of sustained allegations by the end of each year
           (SELECT count(case when B.final_finding = 'SU' then 1 end)
           from allegations_until_2015 B
           where B.year<= A.year and B.officer_id = A.officer_id) as sustained_allegation_count
    from allegations_until_2015 A
    group by A.officer_id, A.year
    order by A.officer_id, A.year
);
-- select * from count_allegations_year;

-- add race and gender to table
drop table if exists active_officers_info;
create temp table active_officers_info as (
    select officer_id,
           year, salary,
           race, gender
    from active_officers
    left join data_officer
    on active_officers.officer_id = data_officer.id
    order by officer_id asc, year
);
-- select * from active_officers_info;

-- now we join salaries and allegations
drop table if exists salaries_and_allegations_year;
create temp table salaries_and_allegations_year as (
    select active_officers_info.officer_id as officer_id, gender, race, active_officers_info.year, salary,
           allegation_count, sustained_allegation_count
    from active_officers_info
    left join count_allegations_year
    on count_allegations_year.officer_id=active_officers_info.officer_id and count_allegations_year.year = active_officers_info.year
    order by active_officers_info.officer_id, active_officers_info.year
);
-- select * from salaries_and_allegations_year;

-- clean s and a
-- now we join salaries and allegations
drop table if exists clean_salaries_and_allegations_year;
create temp table clean_salaries_and_allegations_year as (
    with give_2007_zero as (
        select officer_id, gender, race, year, salary,
           coalesce(allegation_count, case when year = 2007 then 0 end) as allegation_count,
           coalesce(sustained_allegation_count, case when year = 2007 then 0 end) as sustained_allegation_count
            from salaries_and_allegations_year
            order by officer_id asc
        )
    select gender, race, year, salary,
           first_value(allegation_count) over (partition by grp_close1) as allegation,
           first_value(sustained_allegation_count) over (partition by grp_close2) as sustained
           --last_value(give_2007_zero.allegation_count) IGNORE null OVER (ORDER BY officer_id) as allegation_count,
           --coalesce(sustained_allegation_count, case when year = 2007 then 0 end) as sustained_allegation_count
    from (
      select officer_id, gender,race, year, salary, allegation_count, sustained_allegation_count,
             sum(case when allegation_count is not null then 1 end) over (order by officer_id, year) as grp_close1,
             sum(case when sustained_allegation_count is not null then 1 end) over (order by officer_id, year) as grp_close2
      from   give_2007_zero
        ) T
);
select * from clean_salaries_and_allegations_year;
