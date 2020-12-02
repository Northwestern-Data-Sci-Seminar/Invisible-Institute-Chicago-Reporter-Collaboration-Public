/* Percentage of complaints categorized as unknown/other year over year */
with
categories(category, year) as
(
    select c.category, extract(YEAR from a.incident_date)
    from data_officerallegation o
    left join data_allegationcategory c on o.allegation_category_id = c.id
    left join data_allegation a on o.allegation_id = a.crid
),
total_by_year(year, frequency) as
(
    select year, count(*)
    from categories
    group by year
),
unknown_other_by_year(year, frequency) as
(
    select year, count(*)
    from categories
    where category = 'Unknown' or category is NULL
    group by year
)

select t.year, (cast(coalesce(u.frequency, 0)  as float)  / cast(t.frequency as float)) * 100 as percentage
from total_by_year t
left join unknown_other_by_year u on t.year = u.year
where t.year is not null
order by t.year;