select d.category, sum(cat.count) as totalct from (select distinct t.allegation_category_id, count(t.allegation_category_id) from (select distinct officer_id, count(allegation_id) as ct from (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2010'
                                                               and cast(incident_date as date) < '07-15-2014') timespan1
where data_officerallegation.allegation_id = timespan1.crid) timespan1oa group by officer_id order by ct desc limit 744)r, (select distinct data_officerallegation.allegation_category_id, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2010'
                                                               and cast(incident_date as date) < '07-15-2014') timespan1
where data_officerallegation.allegation_id = timespan1.crid) t where t.allegation_category_id is not null and r.officer_id = t.officer_id
group by t.allegation_category_id) cat,
                                                  data_allegationcategory d where d.id = cat.allegation_category_id
group by d.category order by totalct desc;

select d.category, sum(cat.count) as totalct from (select distinct t.allegation_category_id, count(t.allegation_category_id) from (select distinct officer_id, count(allegation_id) as ct from (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2014'
                                                               and cast(incident_date as date) < '07-15-2018') timespan1
where data_officerallegation.allegation_id = timespan1.crid) timespan1oa group by officer_id order by ct desc limit 557)r, (select distinct data_officerallegation.allegation_category_id, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2014'
                                                               and cast(incident_date as date) < '07-15-2018') timespan1
where data_officerallegation.allegation_id = timespan1.crid) t where t.allegation_category_id is not null and r.officer_id = t.officer_id
group by t.allegation_category_id) cat,
                                                  data_allegationcategory d where d.id = cat.allegation_category_id
group by d.category order by totalct desc;

select d.category, sum(cat.count) as totalct from (select distinct t.allegation_category_id, count(t.allegation_category_id) from (select distinct officer_id, count(allegation_id) as ct from (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2006'
                                                               and cast(incident_date as date) < '07-15-2010') timespan1
where data_officerallegation.allegation_id = timespan1.crid) timespan1oa group by officer_id order by ct desc limit 887)r, (select distinct data_officerallegation.allegation_category_id, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2006'
                                                               and cast(incident_date as date) < '07-15-2010') timespan1
where data_officerallegation.allegation_id = timespan1.crid) t where t.allegation_category_id is not null and r.officer_id = t.officer_id
group by t.allegation_category_id) cat,
                                                  data_allegationcategory d where d.id = cat.allegation_category_id
group by d.category order by totalct desc;