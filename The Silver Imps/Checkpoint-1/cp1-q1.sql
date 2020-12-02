--the three timespans would be 2018/07/15-2014/07/15, 2014/07/15-2010/07/15, 2010/07/15-2006/07/15
--timespan1: 2018/07/15-2014/07/15
drop view if exists timespan1 cascade;
create TEMP view timespan1 as (select * from data_allegation where is_officer_complaint is false and incident_date is not null and cast(incident_date as date) >= '07-15-2014' and cast(incident_date as date) < '07-15-2018');
-- select * from timespan1;


drop view if exists timespan1oa cascade;
create TEMP view timespan1oa as (
select distinct data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, timespan1
where data_officerallegation.allegation_id = timespan1.crid);


select count(distinct officer_id) from timespan1oa; --count is 5567; top 10% is 557
--define repeaters for timespan1
drop view if exists timespan1repeater cascade;
create TEMP view timespan1repeater as (
select distinct officer_id, count(allegation_id) as ct from timespan1oa group by officer_id order by ct desc limit 557);




select (select count(*) as total
                        from timespan1oa),
       (select count(*) as cases_of_repeater
                        from timespan1oa,timespan1repeater
                        where timespan1oa.officer_id = timespan1repeater.officer_id),
       (select ((select count(*) from timespan1oa,timespan1repeater
        where timespan1oa.officer_id = timespan1repeater.officer_id))
        * 100.0 / (select count(*) from timespan1oa) as percentage);


--timespan2: 2014/07/15-2010/07/15
drop view if exists timespan2 cascade;
create TEMP view timespan2 as (select * from data_allegation where is_officer_complaint is false and incident_date is not null and cast(incident_date as date) >= '07-15-2010' and cast(incident_date as date) < '07-15-2014');
-- select * from timespan2;


drop view if exists timespan2oa cascade;
create TEMP view timespan2oa as (
select distinct data_officerallegation.allegation_id, data_officerallegation.officer_id from data_officerallegation, timespan2 where data_officerallegation.allegation_id = timespan2.crid);




select count(distinct officer_id) from timespan2oa; --count is 7445; top 10% is 745
--define repeaters for timespan2
drop view if exists timespan2repeater cascade;
create TEMP view timespan2repeater as (
select distinct officer_id, count(allegation_id) as ct from timespan2oa group by officer_id order by ct desc limit 745);


select (select count(*) as total
                        from timespan2oa),
       (select count(*) as cases_of_repeater
                        from timespan2oa,timespan2repeater
                        where timespan2oa.officer_id = timespan2repeater.officer_id),
       (select ((select count(*) from timespan2oa,timespan2repeater
        where timespan2oa.officer_id = timespan2repeater.officer_id))
        * 100.0 / (select count(*) from timespan2oa) as percentage);




--timespan3: 2010/07/15-2006/07/15
drop view if exists timespan3 cascade;
create view timespan3 as (select * from data_allegation where is_officer_complaint is false and incident_date is not null and cast(incident_date as date) >= '07-15-2006' and cast(incident_date as date) < '07-15-2010');
-- select * from timespan3;


drop view if exists timespan3oa cascade;
create TEMP view timespan3oa as (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id from data_officerallegation, timespan3 where data_officerallegation.allegation_id = timespan3.crid);




select count(distinct officer_id) from timespan3oa; --count is 8874; top 10% is 887
--define repeaters for timespan3
drop view if exists timespan3repeater cascade;
create TEMP view timespan3repeater as (
select distinct officer_id, count(allegation_id) as ct from timespan3oa group by officer_id order by ct desc limit 887);




select (select count(*) as total
                        from timespan3oa),
       (select count(*) as cases_of_repeater
                        from timespan3oa,timespan3repeater
                        where timespan3oa.officer_id = timespan3repeater.officer_id),
       (select ((select count(*) from timespan3oa,timespan3repeater
        where timespan3oa.officer_id = timespan3repeater.officer_id))
        * 100.0 / (select count(*) from timespan3oa) as percentage);