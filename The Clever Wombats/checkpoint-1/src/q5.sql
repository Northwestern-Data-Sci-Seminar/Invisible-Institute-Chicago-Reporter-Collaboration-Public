--  Total number allegations per beat per year
drop table if exists allegation_beat_year;
create temp table allegation_beat_year as (
select al.beat_id, extract(year from al.incident_date) as year, count(*) as allegation_count
from data_allegation al
group by al.beat_id, year
order by al.beat_id, year);

drop table if exists allegation_beat_year_filter;
create temp table allegation_beat_year_filter as (
select *
From allegation_beat_year
where allegation_beat_year is not null and year >= 2009 and year <= 2018);

drop table if exists complete;
create temp table complete as (
SELECT beat_id,
MAX(CASE WHEN year = 2009
THEN allegation_count END) AS Year_2009,
MAX(CASE WHEN year = 2010
THEN allegation_count END) AS Year_2010,
MAX(CASE WHEN year = 2011
THEN allegation_count END) AS Year_2011,
MAX(CASE WHEN year = 2012
THEN allegation_count END) AS Year_2012,
MAX(CASE WHEN year = 2013
THEN allegation_count END) AS Year_2013,
MAX(CASE WHEN year = 2014
THEN allegation_count END) AS Year_2014,
MAX(CASE WHEN year = 2015
THEN allegation_count END) AS Year_2015,
MAX(CASE WHEN year = 2016
THEN allegation_count END) AS Year_2016,
MAX(CASE WHEN year = 2017
THEN allegation_count END) AS Year_2017,
MAX(CASE WHEN year = 2018
THEN allegation_count END) AS Year_2018
FROM allegation_beat_year_filter
GROUP BY beat_id
);

select beat_id,
       coalesce(max(year_2009), 0) as year_2009,
       coalesce(max(year_2010), 0) as year_2010,
       coalesce(max(year_2011), 0) as year_2011,
       coalesce(max(year_2012), 0) as year_2012,
       coalesce(max(year_2013), 0) as year_2013,
       coalesce(max(year_2014), 0) as year_2014,
       coalesce(max(year_2015), 0) as year_2015,
       coalesce(max(year_2016), 0) as year_2016,
       coalesce(max(year_2017), 0) as year_2017,
       coalesce(max(year_2018), 0) as year_2018
from complete
GROUP BY beat_id
order by beat_id;
