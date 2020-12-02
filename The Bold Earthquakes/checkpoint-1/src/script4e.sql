with percentage_table as (
    with create_promotions_table as (
        with officer_min_years as (
            select distinct officer_id as oid, min(year) as first_year
            from (select ds.officer_id, ds.rank, ds.salary, ds.rank_changed,coalesce(award_count, 0) as award_count, coalesce(allegation_count, 0) as allegation_count, ds.year
from
     data_salary ds
left outer join (
    SELECT officer_id, date_part('year', start_date) as award_year, count(*) as award_count
FROM data_award
group by officer_id, award_year
order by officer_id desc
         ) da
on
    da.officer_id = ds.officer_id and da.award_year = ds.year
left outer join (
    SELECT officer_id, date_part('year', da.incident_date) as allegation_year, count(*) as allegation_count, final_finding
FROM data_officerallegation doa, data_allegation da
WHERE da.crid = doa.allegation_id
group by officer_id, allegation_year, final_finding
order by officer_id desc
         ) dal
on
    dal.officer_id = ds.officer_id and dal.allegation_year = ds.year
order by ds.officer_id,year) x
            group by oid
        )
        select officer_id, salary, rank_changed, rank, year, allegation_count, award_count, final_finding
        from (select ds.officer_id, ds.rank, ds.salary, ds.rank_changed,coalesce(award_count, 0) as award_count, coalesce(allegation_count, 0) as allegation_count, ds.year, final_finding
from
     data_salary ds
left outer join (
    SELECT officer_id, date_part('year', start_date) as award_year, count(*) as award_count
FROM data_award
group by officer_id, award_year
order by officer_id desc
         ) da
on
    da.officer_id = ds.officer_id and da.award_year = ds.year
left outer join (
    SELECT officer_id, date_part('year', da.incident_date) as allegation_year, count(*) as allegation_count, final_finding
FROM data_officerallegation doa, data_allegation da
WHERE da.crid = doa.allegation_id
group by officer_id, allegation_year, final_finding
order by officer_id desc
         ) dal
on
    dal.officer_id = ds.officer_id and dal.allegation_year = ds.year
order by ds.officer_id,year) y
                 join officer_min_years
                      on officer_min_years.oid = officer_id
        where year > officer_min_years.first_year
    )
    -- HERE IS WHERE WE ENTER ALLEGATION COUNT OR PROMOTIONS VS AWARDS
    -- FOR PROMOTIONS, set rank_changed
    -- FOR AWARDS, set award_count >= 1
    -- FOR ALLEGATIONS, set allegation_count >= n,
    -- FOR ALLEGATIONS SUSTAINED, set final_finding = 'SU
    -- ********* OFFICER COUNT FOR n ALLEGATIONS*********
    select count(case when allegation_count >= 4 then 1 else null end) as officer_count,
    -- ********* OFFICER COUNT FOR n SUSTAINED ALLEGATIONS*********
    -- select count(case when allegation_count >= 1 and final_finding = 'SU' then 1 else null end) as officer_count,
           -- ********* PROMOTIONS AND ALLEGATIONS *********
           -- count(case when rank_changed = true and allegation_count >= 0 then 1 else null end)  as promotions,
           -- count(case when rank_changed = false and allegation_count >= 0 then 1 else null end) as not_promotions,
           -- ********* PROMOTIONS AND SUSTAINED ALLEGATIONS *********
           -- count(case when rank_changed = true and allegation_count >= 1 and final_finding = 'SU' then 1 else null end) as promotions,
           -- count(case when rank_changed = false and allegation_count >= 1 and final_finding = 'SU' then 1 else null end) as not_promotions,
           -- ************ AWARDS AND ALLEGATIONS **********
           count(case when award_count >= 1 and allegation_count >= 4 then 1 else null end)  as promotions,
           count(case when award_count = 0 and allegation_count >= 4 then 1 else null end) as not_promotions,
           -- ********* AWARDS AND SUSTAINED ALLEGATIONS *********
           -- count(case when award_count >= 1 and allegation_count >= 1 and final_finding = 'SU' then 1 else null end) as promotions,
           -- count(case when award_count = 0 and allegation_count >= 1 and final_finding = 'SU' then 1 else null end) as not_promotions,
           year
    from create_promotions_table
    group by year
)
select (promotions/officer_count::float)*100 as perc_adm, officer_count, year
from percentage_table
group by year, promotions, officer_count