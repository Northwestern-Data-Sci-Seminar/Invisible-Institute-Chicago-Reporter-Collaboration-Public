select t6.unit_id, unit_name, unit_desc, total_settlement from
(select id as unit_id, unit_name, description as unit_desc from data_policeunit) as t6
INNER JOIN
(select unit_id, total_settlement from
(select officer_id, unit_id, end_date, effective_date from data_officerhistory) AS t3
inner join
(select * from
(select id, CAST(incident_date as date), total_settlement from lawsuit_lawsuit where total_settlement > 0) AS t1
inner join
(select officer_id, lawsuit_id from lawsuit_lawsuit_officers) AS t2
on t2.lawsuit_id = t1.id) as t4
on t3.officer_id = t4.officer_id
where incident_date <= end_date and incident_date >= effective_date
group by unit_id, total_settlement
order by unit_id) as t5
on t5.unit_id = t6.unit_id;




select district_id, incident_date, disciplined from
(select officer_id, unit_id as district_id, end_date, effective_date from data_officerhistory) AS t4
inner join
(select * from
(select officer_id, allegation_id, disciplined from data_officerallegation) as t1
inner join
(select  CAST(incident_date as date), crid  from data_allegation) as t2
on t1.allegation_id = t2.crid) as t3
on t4.officer_id = t3.officer_id
where incident_date <= end_date and incident_date >= effective_date and district_id <= 26
order by district_id;





