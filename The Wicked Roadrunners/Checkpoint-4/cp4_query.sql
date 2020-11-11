--cp4 question 1: predict discipline
select gender, race, rank, complaint_percentile, allegation_count, category, disciplined from
(select t2.officer_id as officer_id, gender, race, rank, complaint_percentile, allegation_count, disciplined, misconduct_category from

(select id as officer_id, gender, race, rank, complaint_percentile, allegation_count from data_officer) as t2

inner join

(select * from
(select officer_id, disciplined, allegation_id from data_officerallegation) as t1
inner join
(select crid as allegation_id, most_common_category_id as misconduct_category from data_allegation) as t3
on
t1.allegation_id = t3.allegation_id) as t4
on t2.officer_id = t4.officer_id
where gender is not null and race is not null and rank is not null and complaint_percentile is not null and allegation_count is not null and disciplined is not null) as t6
inner join
(select category, id as misconduct_category from data_allegationcategory) as t5
on t5.misconduct_category = t6.misconduct_category
where category is not null;



--cp4 question 2: predict settlement amount
select gender, race, rank, interactions, outcomes, misconducts, violences, primary_cause, total_settlement from
(select id, gender, race, rank from data_officer) as t3
inner join
(select * from
(select id, interactions, outcomes, misconducts, violences, primary_cause, total_settlement from lawsuit_lawsuit) as t1
inner join
(select lawsuit_id, officer_id from lawsuit_lawsuit_officers) as t2
on t1.id = t2.lawsuit_id) as t4
on t3.id = t4.officer_id;
