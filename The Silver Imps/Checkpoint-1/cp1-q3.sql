--What is the distribution of the categories of the misconducts
-- (illegal search, use of force, etc.) for those “repeaters” we defined above?
--timespan1: 2018/07/15-2014/07/15
drop view if exists timespan1 cascade;
create TEMP view timespan1 as (select * from data_allegation where is_officer_complaint is false and incident_date is not null and cast(incident_date as date) >= '07-15-2014' and cast(incident_date as date) < '07-15-2018');
-- select * from timespan1;


drop view if exists timespan1oa cascade;
create TEMP view timespan1oa as (
select distinct data_officerallegation.allegation_category_id, data_officerallegation.allegation_id, data_officerallegation.officer_id from data_officerallegation, timespan1 where data_officerallegation.allegation_id = timespan1.crid);
--select count(*) from timespan1oa;


select count(distinct officer_id) from timespan1oa; --count is 5567, 10% is 557


drop view if exists timespan1repeater cascade;
create TEMP view timespan1repeater as (
select distinct officer_id, count(allegation_id) as ct from timespan1oa group by officer_id order by ct desc limit 557);


drop view if exists timespan1cat cascade;
create TEMP view timespan1cat as (
select distinct t.allegation_category_id, count(t.allegation_category_id) from timespan1repeater r, timespan1oa t where t.allegation_category_id is not null and r.officer_id = t.officer_id group by t.allegation_category_id);


select d.category, sum(t.count) as totalct, sum(t.count) * 100.0 / (select sum(t1.count) from timespan1cat t1) as percentage from data_allegationcategory d, timespan1cat t where d.id = t.allegation_category_id group by d.category order by totalct desc;


--timespan2: 2014/07/15-2010/07/15
drop view if exists timespan2 cascade;
create TEMP view timespan2 as (select * from data_allegation where is_officer_complaint is false and incident_date is not null and cast(incident_date as date) >= '07-15-2010' and cast(incident_date as date) < '07-15-2014');
-- select * from timespan2;


drop view if exists timespan2oa cascade;
create TEMP view timespan2oa as (
select distinct data_officerallegation.allegation_category_id, data_officerallegation.allegation_id, data_officerallegation.officer_id from data_officerallegation, timespan2 where data_officerallegation.allegation_id = timespan2.crid);
--select count(*) from timespan2oa;


select count(distinct officer_id) from timespan2oa; --count is 7445, 10% is 745


drop view if exists timespan2repeater cascade;
create TEMP view timespan2repeater as (
select distinct officer_id, count(allegation_id) as ct from timespan2oa group by officer_id order by ct desc limit 745);


drop view if exists timespan2cat cascade;
create TEMP view timespan2cat as (
select distinct t.allegation_category_id, count(t.allegation_category_id) from timespan2repeater r, timespan2oa t where t.allegation_category_id is not null and r.officer_id = t.officer_id group by t.allegation_category_id);


select d.category, sum(t.count) as totalct, sum(t.count) * 100.0 / (select sum(t2.count) from timespan2cat t2) as percentage from data_allegationcategory d, timespan2cat t where d.id = t.allegation_category_id group by d.category order by totalct desc;


--timespan3: 2010/07/15-2006/07/15
drop view if exists timespan3 cascade;
create TEMP view timespan3 as (select * from data_allegation where is_officer_complaint is false and incident_date is not null and cast(incident_date as date) >= '07-15-2006' and cast(incident_date as date) < '07-15-2010');
-- select * from timespan3;


drop view if exists timespan3oa cascade;
create TEMP view timespan3oa as (
select distinct data_officerallegation.allegation_category_id, data_officerallegation.allegation_id, data_officerallegation.officer_id from data_officerallegation, timespan3 where data_officerallegation.allegation_id = timespan3.crid);
--select count(*) from timespan3oa;


select count(distinct officer_id) from timespan3oa; --count is 8874, 10% is 887


drop view if exists timespan3repeater cascade;
create TEMP view timespan3repeater as (
select distinct officer_id, count(allegation_id) as ct from timespan3oa group by officer_id order by ct desc limit 887);


drop view if exists timespan3cat cascade;
create TEMP view timespan3cat as (
select distinct t.allegation_category_id, count(t.allegation_category_id) from timespan3repeater r, timespan3oa t where t.allegation_category_id is not null and r.officer_id = t.officer_id group by t.allegation_category_id);

select d.category, sum(t.count) as totalct, sum(t.count) * 100.0 / (select sum(t3.count) from timespan3cat t3) as percentage from data_allegationcategory d, timespan3cat t where d.id = t.allegation_category_id group by d.category order by totalct desc;