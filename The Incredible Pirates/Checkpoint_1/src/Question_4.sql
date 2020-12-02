
-- This code will answer question 4 of checkpoint 1:
-- to view the tables in different orders, just replace order by with the appropriate column header
	
SELECT officer_id, count(*) as total_use_of_force_events,
       count(case when subject_injured = 'True' then 1 end) as subject_injured,
       count(case when subject_injured = 'True' then 1 end)*100/count(*) as_percent_of_events
from trr_trr
group by officer_id
order by subject_injured desc
;





