-- all of the home invasion allegations --
drop table if exists officer_allegations;

create temp table officer_allegations as (
    WITH officer_allegations AS (SELECT *
                                 FROM data_allegationcategory
                                          INNER JOIN data_officerallegation d
                                                     on data_allegationcategory.id = d.allegation_category_id
                                          INNER JOIN data_allegation on d.allegation_id = data_allegation.crid
                                          INNER JOIN data_officer o on d.officer_id = o.id
                                 WHERE allegation_name = 'Search Of Premise Without Warrant'),
         allegations_home_distinct AS (SELECT DISTINCT allegation_id
                                       FROM officer_allegations
                                       WHERE location = 'Residence'
                                          OR location = 'Apartment'
                                          OR location = 'Private Residence'
                                          OR location = 'Other Private Premise')
    SELECT DISTINCT allegations_home_distinct.allegation_id AS allegation_id,
                    extract(day from incident_date) as day,
                    extract(month from incident_date) as month,
                    extract(year from incident_date) as year,
                    add1,
                    add2,
                    city,
                    incident_date,
                    beat_id,
                    location
    FROM allegations_home_distinct
             INNER JOIN officer_allegations ON
            allegations_home_distinct.allegation_id = officer_allegations.allegation_id
);

-- now get count of home invasion allegations per year --
select year, count(year) as allegs_per_year from officer_allegations
group by year
order by year;