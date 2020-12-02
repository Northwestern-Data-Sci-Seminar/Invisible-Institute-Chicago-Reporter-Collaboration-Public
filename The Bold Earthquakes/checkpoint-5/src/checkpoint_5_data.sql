drop table if exists categories;
create temp table categories as (
    select id, category, allegation_name
    from data_allegationcategory
);
-- select * from categories;

drop table if exists allegations;
create temp table allegations as (
    with t as (
        select allegation_id as crid, categories.id as category_id, category, allegation_name
        from data_officerallegation
        left join categories
        on data_officerallegation.allegation_category_id=categories.id
    )
    select * from t
    where crid is not null
    group by crid, category_id, category, allegation_name
    order by crid asc
);
select * from allegations