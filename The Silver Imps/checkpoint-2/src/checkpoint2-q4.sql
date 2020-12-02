select count(*), timespan1oa.disciplined from(select distinct officer_id, count(allegation_id) as ct from (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2006' and cast(incident_date as date) < '07-15-2010') timespan1
where data_officerallegation.allegation_id = timespan1.crid) timespan1oa group by officer_id order by ct desc limit 887)x,  (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2006' and cast(incident_date as date) < '07-15-2010') timespan1
where data_officerallegation.allegation_id = timespan1.crid) timespan1oa
where timespan1oa.disciplined is not null and timespan1oa.officer_id = x.officer_id group by timespan1oa.disciplined;

select count(*), timespan1oa.disciplined from(select distinct officer_id, count(allegation_id) as ct from (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2010' and cast(incident_date as date) < '07-15-2014') timespan1
where data_officerallegation.allegation_id = timespan1.crid) timespan1oa group by officer_id order by ct desc limit 744)x,  (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2010' and cast(incident_date as date) < '07-15-2014') timespan1
where data_officerallegation.allegation_id = timespan1.crid) timespan1oa
where timespan1oa.disciplined is not null and timespan1oa.officer_id = x.officer_id group by timespan1oa.disciplined;

select count(*), timespan1oa.disciplined from(select distinct officer_id, count(allegation_id) as ct from (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2014' and cast(incident_date as date) < '07-15-2018') timespan1
where data_officerallegation.allegation_id = timespan1.crid) timespan1oa group by officer_id order by ct desc limit 557)x,  (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2014' and cast(incident_date as date) < '07-15-2018') timespan1
where data_officerallegation.allegation_id = timespan1.crid) timespan1oa
where timespan1oa.disciplined is not null and timespan1oa.officer_id = x.officer_id group by timespan1oa.disciplined;