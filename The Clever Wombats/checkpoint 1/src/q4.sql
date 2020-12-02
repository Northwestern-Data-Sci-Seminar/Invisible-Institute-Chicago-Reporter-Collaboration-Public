drop table if exists allegation_type_by_year;
create temp table allegation_type_by_year as (
select o.officer_id, o.year, sus.SU, ot.other
from (select officer_id, extract(year from start_date) as year
    from data_officerallegation
    where officer_id in (select id from officer_gt)) as o
left join (select officer_id, extract(year from start_date) as year, count(*) as other
from data_officerallegation
where final_finding != 'SU' and
      final_finding != 'NS' and
      officer_id in (select id from officer_gt)
group by officer_id, year
    ) as ot
on o.officer_id = ot.officer_id and
   o.year = ot.year
left join (select officer_id, extract(year from start_date) as year, count(*) as SU
from data_officerallegation
where final_finding = 'SU' and
      officer_id in (select id from officer_gt)
group by officer_id, year
    ) as sus
on o.officer_id = sus.officer_id and
   o.year = sus.year
);

select a.*, nsus.NS
from allegation_type_by_year a
left join (select officer_id, extract(year from start_date) as year, count(*) as NS
from data_officerallegation
where final_finding = 'NS' and
      officer_id in (select id from officer_gt)
group by officer_id, year
    ) as nsus
on a.officer_id = nsus.officer_id and
   a.year = nsus.year
order by a.officer_id, a.year;