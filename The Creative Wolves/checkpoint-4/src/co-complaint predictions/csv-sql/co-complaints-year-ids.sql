--Top 4000 officers with most complaints
DROP  TABLE IF EXISTS top_officer_complaints;
CREATE TEMP TABLE top_officer_complaints
AS (SELECT DISTINCT id, first_name, last_name, allegation_count
FROM data_officer
group by id
ORDER BY allegation_count DESC
LIMIT 4000);

-- pairs of officers among the 4000 repeaters with number of complaiints they got together every year
-- where complaints were sustained as final finding.
SELECT a.officer_id as o1, b.officer_id as o2, extract(year from a.start_date) as year
     , count(*) as coComplaints
FROM data_officerallegation a join data_officerallegation b
on a.allegation_id = b.allegation_id
where a.officer_id < b.officer_id
and a.officer_id in (select id from top_officer_complaints)
and b.officer_id in (select id from top_officer_complaints)
-- and a.final_finding = 'SU'
group by a.officer_id, b.officer_id, year
order by coComplaints DESC;