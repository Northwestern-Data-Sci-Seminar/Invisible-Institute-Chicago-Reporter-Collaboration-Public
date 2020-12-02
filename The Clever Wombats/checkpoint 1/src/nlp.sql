drop table if exists summaries;
create temp table summaries as (
select CRID as allegation_id, SUMMARY, BEAT_ID from data_allegation
where not TRIM(summary) = '');

select * from summaries;

drop table if exists findings;
create temp table findings as (
select allegation_id, final_finding
from data_officerallegation
where final_finding = 'SU' or final_finding = 'NS'
);

select * from findings;

drop table if exists nlp;
create temp table nlp as (
    select sum.allegation_id, sum.SUMMARY, sum.BEAT_ID, find.final_finding
    from summaries sum
    inner join (select allegation_id, final_finding
    from findings) find
    on sum.allegation_id = find.allegation_id
    where sum.allegation_id is not null and sum.SUMMARY is not null and sum.BEAT_ID is not null and find.final_finding is not null
);

select * from nlp;