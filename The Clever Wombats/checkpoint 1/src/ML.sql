drop table if exists officer_years_allegs;
create temp table officer_years_allegs as (
select t1.officer_id as officer_id, allegation_count, years_on_force from
(select officer_id, count(*) as allegation_count from data_officerallegation group by officer_id) as t1
inner join
(SELECT id as officer_id, DATE_PART('year', end_date::date) - DATE_PART('year', effective_date::date) as years_on_force from data_officerhistory where end_date is not null) as t2
on t1.officer_id = t2.officer_id);

select t1.officer_id as officer_id, allegation_count, years_on_force, salary, rank from
(select officer_id, allegation_count, years_on_force from officer_years_allegs) as t1
inner join
(select officer_id, salary, rank from data_salary) as t2
on t1.officer_id = t2.officer_id
where rank='Detective'
