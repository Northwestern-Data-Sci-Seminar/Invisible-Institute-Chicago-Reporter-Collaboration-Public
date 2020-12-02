/* Complaint frequency by category */
with
categories(category, finding) as
(
    select c.category, o.final_finding
    from data_officerallegation o
    left join data_allegationcategory c on o.allegation_category_id = c.id
),
allegations_by_category(category, frequency) as
(
    select category, count(*)
    from categories
    group by category
),
sustained_by_category(category, frequency) as
(
    select category, count(*)
    from categories
    where finding = 'SU'
    group by category
)

select coalesce(a.category, 'No Category') as category, a.frequency as total, coalesce(s.frequency, 0) as sustained, a.frequency - coalesce(s.frequency, 0) as unsustained
from allegations_by_category a
left join sustained_by_category s on a.category = s.category;