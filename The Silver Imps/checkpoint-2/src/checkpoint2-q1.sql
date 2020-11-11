select (select count(*) as total
                        from (
select distinct data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false and incident_date is not null and cast(incident_date as date) >= '07-15-2010' and cast(incident_date as date) < '07-15-2014')timespan2
where data_officerallegation.allegation_id = timespan2.crid)timespan2oa),
       (select sum(timespan2repeater.ct) as cases_of_repeater
                        from (select distinct officer_id, count(allegation_id) as ct from (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2010'
                                                               and cast(incident_date as date) < '07-15-2014') timespan2
where data_officerallegation.allegation_id = timespan2.crid) timespan2oa group by officer_id order by ct desc limit 744)timespan2repeater),
                             (select ((select sum(timespan2repeater.ct) as cases_of_repeater
                        from (select distinct officer_id, count(allegation_id) as ct from (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2010'
                                                               and cast(incident_date as date) < '07-15-2014') timespan2
where data_officerallegation.allegation_id = timespan2.crid) timespan2oa group by officer_id order by ct desc limit 744)timespan2repeater))
        * 100.0 / (select count(*) as total
                        from (
select distinct data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false and incident_date is not null and cast(incident_date as date) >= '07-15-2010' and cast(incident_date as date) < '07-15-2014')timespan2
where data_officerallegation.allegation_id = timespan2.crid)timespan2oa) as percentage);

select (select count(*) as total
                        from (
select distinct data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false and incident_date is not null and cast(incident_date as date) >= '07-15-2006' and cast(incident_date as date) < '07-15-2010')timespan2
where data_officerallegation.allegation_id = timespan2.crid)timespan2oa),
       (select sum(timespan2repeater.ct) as cases_of_repeater
                        from (select distinct officer_id, count(allegation_id) as ct from (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2006'
                                                               and cast(incident_date as date) < '07-15-2010') timespan2
where data_officerallegation.allegation_id = timespan2.crid) timespan2oa group by officer_id order by ct desc limit 887)timespan2repeater),
                             (select ((select sum(timespan2repeater.ct) as cases_of_repeater
                        from (select distinct officer_id, count(allegation_id) as ct from (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2006'
                                                               and cast(incident_date as date) < '07-15-2010') timespan2
where data_officerallegation.allegation_id = timespan2.crid) timespan2oa group by officer_id order by ct desc limit 887)timespan2repeater))
        * 100.0 / (select count(*) as total
                        from (
select distinct data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false and incident_date is not null and cast(incident_date as date) >= '07-15-2006' and cast(incident_date as date) < '07-15-2010')timespan2
where data_officerallegation.allegation_id = timespan2.crid)timespan2oa) as percentage);

select (select count(*) as total
                        from (
select distinct data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false and incident_date is not null and cast(incident_date as date) >= '07-15-2014' and cast(incident_date as date) < '07-15-2018')timespan2
where data_officerallegation.allegation_id = timespan2.crid)timespan2oa),
       (select sum(timespan2repeater.ct) as cases_of_repeater
                        from (select distinct officer_id, count(allegation_id) as ct from (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2014'
                                                               and cast(incident_date as date) < '07-15-2018') timespan2
where data_officerallegation.allegation_id = timespan2.crid) timespan2oa group by officer_id order by ct desc limit 557)timespan2repeater),
                             (select ((select sum(timespan2repeater.ct) as cases_of_repeater
                        from (select distinct officer_id, count(allegation_id) as ct from (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2014'
                                                               and cast(incident_date as date) < '07-15-2018') timespan2
where data_officerallegation.allegation_id = timespan2.crid) timespan2oa group by officer_id order by ct desc limit 557)timespan2repeater))
        * 100.0 / (select count(*) as total
                        from (
select distinct data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false and incident_date is not null and cast(incident_date as date) >= '07-15-2014' and cast(incident_date as date) < '07-15-2018')timespan2
where data_officerallegation.allegation_id = timespan2.crid)timespan2oa) as percentage);