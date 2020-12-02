drop table if exists findings_beat_month;
create temp table findings_beat_month as (
select a.incident_date, a.beat_id, da.final_finding
from data_officerallegation as da
inner join (select crid, beat_id, incident_date
from data_allegation) a
on a.crid = da.allegation_id
where a.beat_id is not null and da.final_finding != '');

select beat_id,
       extract(year from incident_date) as year,
       sum(case when final_finding='NS' then 1 else 0 end) as ns,
       sum(case when final_finding='SU' then 1 else 0 end) as su,
       sum(case when final_finding!='NS' and final_finding!='SU' then 1 else 0 end) as other
from findings_beat_month
group by beat_id, year
order by beat_id, year;

select * from findings_beat_month
order by incident_date;