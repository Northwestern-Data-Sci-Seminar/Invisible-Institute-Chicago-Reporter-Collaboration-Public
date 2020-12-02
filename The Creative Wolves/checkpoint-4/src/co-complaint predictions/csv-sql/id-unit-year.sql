--Top 4000 officers with most complaints
DROP  TABLE IF EXISTS top_officer_complaints;
CREATE TEMP TABLE top_officer_complaints
AS (SELECT DISTINCT id, first_name, last_name, allegation_count
FROM data_officer
group by id
ORDER BY allegation_count DESC
LIMIT 4000);

-- -- answers "Which repeater was placed in which unit in a specific year"
select officer_id, unit_id, extract(year from effective_date) as year
from data_officerhistory
where officer_id in (select id from top_officer_complaints)
-- group by officer_id, unit_id, start, end;
