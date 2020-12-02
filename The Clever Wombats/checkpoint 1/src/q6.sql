--  non-sustained number allegations per beat per year
drop table if exists findings_beat_year;
create temp table findings_beat_year as (
select a.year, a.beat_id, da.final_finding
from data_officerallegation as da
inner join (select crid, beat_id, extract(year from incident_date) as year
from data_allegation) a
on a.crid = da.allegation_id);

drop table if exists findings_beat_year_NS;
create temp table findings_beat_year_NS as (
select * from findings_beat_year
where year >= 2009 and year <= 2018 and final_finding = 'NS' and beat_id is not null
);

drop table if exists allegation_beat_year_NS;
create temp table allegation_beat_year_NS as (
select ns.beat_id, ns.year, count(*) as allegation_count
from findings_beat_year_NS ns
group by ns.beat_id, year
order by ns.beat_id, year);

-- select * from allegation_beat_year_NS
-- group by year, beat_id, allegation_count
-- order by year, beat_id;


drop table if exists complete_NS;
create temp table complete_NS as (
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
FROM allegation_beat_year_NS
GROUP BY beat_id
);

drop table if exists needs_prefix_NS;
create temp table needs_prefix_NS as (
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
from complete_NS
GROUP BY beat_id
order by beat_id);

--  sustained number allegations per beat per year
drop table if exists findings_beat_year_2;
create temp table findings_beat_year_2 as (
select a.year, a.beat_id, da.final_finding
from data_officerallegation as da
inner join (select crid, beat_id, extract(year from incident_date) as year
from data_allegation) a
on a.crid = da.allegation_id);

drop table if exists findings_beat_year_SU;
create temp table findings_beat_year_SU as (
select * from findings_beat_year_2
where year >= 2009 and year <= 2018 and final_finding = 'SU' and beat_id is not null
);

drop table if exists allegation_beat_year_SU;
create temp table allegation_beat_year_SU as (
select su.beat_id, su.year, count(*) as allegation_count
from findings_beat_year_SU su
group by su.beat_id, year
order by su.beat_id, year);

-- select * from allegation_beat_year_SU
-- group by year, beat_id, allegation_count
-- order by year, beat_id;

drop table if exists complete_SU;
create temp table complete_SU as (
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
FROM allegation_beat_year_SU
GROUP BY beat_id
);

drop table if exists needs_prefix_SU;
create temp table needs_prefix_SU as (
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
from complete_SU
GROUP BY beat_id
order by beat_id);

drop table if exists together;
create temp table together as (
select ns.beat_id, ns.year_2009 as ns_2009, su.year_2009 as su_2009
from needs_prefix_NS ns
left join (select beat_id, year_2009 from needs_prefix_SU) su
on ns.beat_id = su.beat_id);



drop table if exists pls_no_errors;
create temp table pls_no_errors as (
select beat_id,
       coalesce(max(ns_2009), 0) as ns_2009,
       coalesce(max(su_2009), 0) as su_2009
from together
GROUP BY beat_id
order by beat_id);


-- select * from pls_no_errors