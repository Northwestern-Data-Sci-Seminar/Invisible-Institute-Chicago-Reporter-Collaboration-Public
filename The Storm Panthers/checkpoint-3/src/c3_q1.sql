-- combine race percentages and illegal search allegation count
drop table if exists races_allegations;

create temp table races_allegations as (
	select distinct data_area.id,
	       round((white.c::decimal/total.c*100), 2) as percent_white,
	       round((black.c::decimal/total.c*100), 2) as percent_black,
	       round((hispanic.c::decimal/total.c*100), 2) as percent_hispanic,
	       round((asian.c::decimal/total.c*100), 2) as percent_asian,
	       round((other.c::decimal/total.c*100), 2) as percent_other,
	        allegation_count.c as allegation_count
	       from data_area
	left join data_racepopulation on data_area.id = data_racepopulation.area_id
	left join (
	    select area_id, sum(count) as c from data_racepopulation
	    group by area_id) total on total.area_id = data_area.id
	left join (select area_id, sum(count) as c from data_racepopulation
	    where race = 'White' group by area_id) white on white.area_id = data_area.id
	left join (select area_id, sum(count) as c from data_racepopulation
	    where race = 'Black' group by area_id) black on black.area_id = data_area.id
	left join (select area_id, sum(count) as c from data_racepopulation
	    where race = 'Hispanic' group by area_id) hispanic on hispanic.area_id = data_area.id
	left join (select area_id, sum(count) as c from data_racepopulation
	    where race = 'Asian' group by area_id) asian on asian.area_id = data_area.id
	left join (select area_id, sum(count) as c from data_racepopulation
	    where race = 'Other' group by area_id) other on other.area_id = data_area.id
	left join (
	    select da2.id, count(distinct data_allegation.crid) as c
	    from data_allegation
	        inner join data_officerallegation on data_allegation.crid = data_officerallegation.allegation_id
	        inner join data_allegationcategory on data_officerallegation.allegation_category_id = data_allegationcategory.id
	        inner join data_allegation_areas on data_allegation.crid = data_allegation_areas.allegation_id
	        inner join data_area da on data_allegation_areas.area_id = da.id
	        cross join data_area da2
	    where st_contains(da2.polygon,st_centroid(da.polygon)) = TRUE
        and da1
	    and da2.area_type = 'community'
	    and data_allegationcategory.allegation_name = 'Search Of Premise Without Warrant'
-- 	    and (location = 'Residence' or location = 'Apartment' or location = 'Private Residence'
-- 	            or location = 'XX' or location = '' or location is Null
-- 	            )
	    group by da2.id, da2.name
	) allegation_count on allegation_count.id = data_area.id
	where data_area.area_type = 'community' or data_area.area_type = 'police districts'
);

select sum(allegation_count) from races_allegations;
--
-- -- now add in area information (polygon, etc)
-- drop table if exists areas_races_allegations;
--
-- create temp table areas_races_allegations as (
--     select *
--     from data_area
--              inner join races_allegations using (id)
-- );
--
-- -- prep for geojson
-- SELECT row_to_json(fc) as data_geometry
-- FROM (SELECT 'FeatureCollection' As type, array_to_json(array_agg(f)) As features
--       FROM (SELECT 'Feature' As type
--                  , ST_AsGeoJSON(lg.polygon, 4)::json As geometry
--                  , row_to_json((SELECT l
--                                 FROM (SELECT DISTINCT id, area_type, median_income,
--                                                       percent_asian, percent_black,
--                                                       percent_hispanic, percent_native_american,
--                                                       percent_other, percent_white,
--                                                       allegation_count) As l
--           )) As properties
--             FROM areas_races_allegations As lg) As f) As fc;
