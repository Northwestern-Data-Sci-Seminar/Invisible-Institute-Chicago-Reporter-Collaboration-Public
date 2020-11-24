-- cp5 --
select summary, rank, years_on_force, disciplined, category, allegation_name from
(select summary, allegation_category_id, rank, years_on_force, disciplined from
(select summary, allegation_category_id, officer_id, disciplined from
(select crid, most_common_category_id, summary from data_allegation where summary is not null and summary != '') as t1
INNER JOIN
(select allegation_category_id, officer_id, disciplined, allegation_id from data_officerallegation) as t2
on t1.crid = t2.allegation_id) as t3
INNER JOIN
(select id as officer_id, rank, (2020 - EXTRACT(YEAR  from appointed_date)) as years_on_force from data_officer) as t4
on t3.officer_id = t4.officer_id) as t5
INNER JOIN
(select id, category, allegation_name from data_allegationcategory) as t6
on t5.allegation_category_id = t6.id;