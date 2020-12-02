
-- This code will answer question 3 of checkpoint 1:
-- to view the tables in different orders, just replace order by with the appropriate column header

SELECT beat, count(*) total_events,
       count(case when officer_injured = 'True' then 1 end) as officer_injured,
       count(case when officer_injured = 'True' then 1 end)*100/count(*) as percent_officer_injured,
       count(case when subject_injured = 'True' then 1 end) as subject_injured,
       count(case when subject_injured = 'True' then 1 end)*100/count(*) as percent_subject_injured
from trr_trr
group by beat
order by officer_injured desc
;






