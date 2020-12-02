with
 repeaters as
     (
        select officer_id, count(*) as number_of_allegations
        from data_officerallegation
        group by officer_id
        order by number_of_allegations desc
        limit 4000
     ),
 repeaters_award as
     (
        select data_award.officer_id, count(*) as number_of_awards
        from data_award
            join repeaters on repeaters.officer_id = data_award.officer_id
        group by data_award.officer_id
     ),
 max_salary as (
         select max(salary) as salary, officer_id
         from data_salary
         group by officer_id
     ),
 repeaters_salary as
     (
        select max_salary.officer_id, salary
        from max_salary
            join repeaters on repeaters.officer_id = max_salary.officer_id
     )
select id, gender, race, rank, (2020 - birth_year) as age, (2020 - EXTRACT(YEAR from appointed_date)) as career_length,
       complaint_percentile, civilian_allegation_percentile, allegation_count,
       sustained_count, civilian_compliment_count, discipline_count, unsustained_count,
       number_of_awards, salary
from data_officer
join
    (select officer_id, count(*) as number_of_allegations
    from data_officerallegation
    group by officer_id
    order by number_of_allegations desc
    limit 4000) as repeaters on id = officer_id
join repeaters_award on id = repeaters_award.officer_id
join repeaters_salary on id = repeaters_salary.officer_id
where rank is not null