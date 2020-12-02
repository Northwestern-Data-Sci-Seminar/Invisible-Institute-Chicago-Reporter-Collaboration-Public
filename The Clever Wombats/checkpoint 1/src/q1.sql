-- Select the number of allegations over time, aggregated by year
select oa.officer_id, extract(year from oa.start_date) as year, count(*)
from data_officerallegation oa
join officer_gt gt
on oa.officer_id = gt.id
group by oa.officer_id, year
order by oa.officer_id, year;
