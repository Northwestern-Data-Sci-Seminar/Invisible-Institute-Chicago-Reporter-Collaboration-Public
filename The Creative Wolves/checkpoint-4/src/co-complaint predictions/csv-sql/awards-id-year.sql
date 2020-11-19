--Top 4000 officers with most complaints
DROP  TABLE IF EXISTS top_officer_complaints;
CREATE TEMP TABLE top_officer_complaints
AS (SELECT DISTINCT id, first_name, last_name, allegation_count
FROM data_officer
group by id
ORDER BY allegation_count DESC
LIMIT 4000);

-- answers "Which repeater got how many awards (not denied) under which rank in a specific year.
select officer_id, rank, extract(year from start_date) as year, count(*) as awards_per_year
from data_award
where current_status != 'Denied'
and officer_id in (select id from top_officer_complaints)
group by officer_id, year, rank