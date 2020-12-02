drop table if exists allegation_cat_year;
create temp table allegation_cat_year as (
select most_common_category_id, extract(year from incident_date) as year, count(*) as category_count
from data_allegation
GROUP BY year, most_common_category_id
order by year
);

drop table if exists output;
create temp table output as (
select most_common_category_id, year, category_count, category
from allegation_cat_year as t1
inner join
(select id, category from data_allegationcategory) as t2
on t1.most_common_category_id = t2.id);

drop table if exists result;
create temp table result as (
select year, category, count(*) as category_count
from output
GROUP BY year, category
order by year
);

drop table if exists result_no_null;
create temp table result_no_null as (
select *
from result
where result is not null
);


drop table if exists result_two;
create temp table result_two as (
SELECT year,
MAX(CASE WHEN category ='Operation/Personnel Violations'
THEN category_count END) AS Operation_Personnel_Violations,
MAX(CASE WHEN category = 'Verbal Abuse'
THEN category_count END) AS Verbal_Abuse,
MAX(CASE WHEN category = 'Conduct Unbecoming (Off-Duty)'
THEN category_count END) AS Conduct_Unbecoming,
MAX(CASE WHEN category = 'Drug / Alcohol Abuse'
THEN category_count END) AS Drug_Alcohol_Abuse,
MAX(CASE WHEN category ='Lockup Procedures'
THEN category_count END) AS Lockup_Procedures,
MAX(CASE WHEN category ='Traffic'
THEN category_count END) AS Traffic,
MAX(CASE WHEN category ='First Amendment'
THEN category_count END) AS First_Amendment,
MAX(CASE WHEN category ='Illegal Search'
THEN category_count END) AS Illegal_Search,
MAX(CASE WHEN category ='False Arrest'
THEN category_count END) AS False_Arrest,
MAX(CASE WHEN category ='Use Of Force'
THEN category_count END) AS Use_Of_Force,
MAX(CASE WHEN category ='Racial Profiling'
THEN category_count END) AS Racial_Profiling,
MAX(CASE WHEN category ='Domestic'
THEN category_count END) AS Domestic,
MAX(CASE WHEN category ='Unknown'
THEN category_count END) AS Unknown,
MAX(CASE WHEN category ='Bribery / Official Corruption'
THEN category_count END) AS Bribery_Official_Corruption,
MAX(CASE WHEN category ='Criminal Misconduct'
THEN category_count END) AS Criminal_Misconduct,
MAX(CASE WHEN category ='Supervisory Responsibilities'
THEN category_count END) AS Supervisory_Responsibilities,
MAX(CASE WHEN category ='Money / Property'
THEN category_count END) AS Money_Property,
MAX(CASE WHEN category ='Medical'
THEN category_count END) AS Medical,
MAX(CASE WHEN category ='Excessive Force'
THEN category_count END) AS Excessive_Force
FROM result_no_null
GROUP BY year
);

select year, coalesce(max(Operation_Personnel_Violations), 0) as Operation_Personnel_Violations,
       coalesce(max(Verbal_Abuse), 0) as Verbal_Abuse,
       coalesce(max(Conduct_Unbecoming), 0) as Conduct_Unbecoming,
       coalesce(max(Drug_Alcohol_Abuse), 0) as Drug_Alcohol_Abuse,
       coalesce(max(Lockup_Procedures), 0) as Lockup_Procedures,
       coalesce(max(Traffic), 0) as Traffic,
       coalesce(max(First_Amendment), 0) as First_Amendment,
       coalesce(max(Illegal_Search), 0) as Illegal_Search,
       coalesce(max(False_Arrest), 0) as False_Arrest,
       coalesce(max(Use_Of_Force), 0) as Use_Of_Force,
       coalesce(max(Racial_Profiling), 0) as Racial_Profiling,
       coalesce(max(Domestic), 0) as Domestic,
       coalesce(max(Unknown), 0) as Unknown,
       coalesce(max(Bribery_Official_Corruption), 0) as Bribery_Official_Corruption,
       coalesce(max(Criminal_Misconduct), 0) as Criminal_Misconduct,
       coalesce(max(Supervisory_Responsibilities), 0) as Supervisory_Responsibilities,
       coalesce(max(Money_Property), 0) as Money_Property,
       coalesce(max(Medical), 0) as Medical
from result_two
GROUP BY year
order by year;
