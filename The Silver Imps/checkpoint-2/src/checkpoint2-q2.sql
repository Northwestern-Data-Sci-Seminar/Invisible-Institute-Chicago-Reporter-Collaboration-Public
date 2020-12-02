select distinct officer_id, data_officer.race, data_officer.gender,
        case when (2020 - data_officer.birth_year) < 30 then 'younger than 30'
            when (2020 - data_officer.birth_year) between 30 and 40 then '30 - 40'
            when (2020 - data_officer.birth_year) between 40 and 50 then '40 - 50'
            when (2020 - data_officer.birth_year) between 50 and 60 then '50 - 60'
            when (2020 - data_officer.birth_year) >= 60 then 'older than 60'
        end as age_range
 from data_officer, (
select distinct officer_id, count(allegation_id) as ct from (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2014'
                                                               and cast(incident_date as date) < '07-15-2018') timespan1
where data_officerallegation.allegation_id = timespan1.crid) timespan1oa group by officer_id order by ct desc limit 557)x
where x.officer_id = data_officer.id

select distinct officer_id, data_officer.race, data_officer.gender,
        case when (2020 - data_officer.birth_year) < 30 then 'younger than 30'
            when (2020 - data_officer.birth_year) between 30 and 40 then '30 - 40'
            when (2020 - data_officer.birth_year) between 40 and 50 then '40 - 50'
            when (2020 - data_officer.birth_year) between 50 and 60 then '50 - 60'
            when (2020 - data_officer.birth_year) >= 60 then 'older than 60'
        end as age_range
 from data_officer, (
select distinct officer_id, count(allegation_id) as ct from (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2010'
                                                               and cast(incident_date as date) < '07-15-2014') timespan1
where data_officerallegation.allegation_id = timespan1.crid) timespan1oa group by officer_id order by ct desc limit 744)x
where x.officer_id = data_officer.id

select distinct officer_id, data_officer.race, data_officer.gender,
        case when (2020 - data_officer.birth_year) < 30 then 'younger than 30'
            when (2020 - data_officer.birth_year) between 30 and 40 then '30 - 40'
            when (2020 - data_officer.birth_year) between 40 and 50 then '40 - 50'
            when (2020 - data_officer.birth_year) between 50 and 60 then '50 - 60'
            when (2020 - data_officer.birth_year) >= 60 then 'older than 60'
        end as age_range
 from data_officer, (
select distinct officer_id, count(allegation_id) as ct from (
select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id
from data_officerallegation, (select * from data_allegation where is_officer_complaint is false
                                                               and incident_date is not null and cast(incident_date as date) >= '07-15-2006'
                                                               and cast(incident_date as date) < '07-15-2010') timespan1
where data_officerallegation.allegation_id = timespan1.crid) timespan1oa group by officer_id order by ct desc limit 887)x
where x.officer_id = data_officer.id
