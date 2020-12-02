-- Really just setup
drop table if exists officer_gt;
create temp table officer_gt as (
    select *
    from data_officer
    where allegation_count > 5
);