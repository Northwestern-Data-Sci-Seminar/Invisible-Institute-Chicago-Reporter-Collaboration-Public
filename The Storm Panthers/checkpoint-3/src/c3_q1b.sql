/* home invasions where polygon is not null */
drop table if exists home_invasions;

create temp table home_invasions as (
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
                    point,
                    add2                                    as street_address,
                    extract(year from incident_date)        as year,
                    location                                as location_type
    FROM allegations_home_distinct
             INNER JOIN officer_allegations ON
            allegations_home_distinct.allegation_id = officer_allegations.allegation_id
    where st_asgeojson(point) is not null
);

-- convert to geojson
-- grab all columns as properties
SELECT row_to_json(fc) as home_invasions_json
FROM (SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
      FROM (SELECT 'Feature' As type
                 , ST_AsGeoJSON(lg.point, 4)::json As geometry
                 , row_to_json((SELECT l
                                FROM (SELECT street_address, year, location_type) As l
          )) As properties
            FROM home_invasions As lg) As f) As fc;
