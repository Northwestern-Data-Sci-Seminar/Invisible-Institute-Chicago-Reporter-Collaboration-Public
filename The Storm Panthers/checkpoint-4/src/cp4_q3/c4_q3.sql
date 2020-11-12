-- Can we predict which officers will be implicated in home invasion complaints in the future
-- based on history of complaint types and officer demographics?

-- Officers implicated in home invasions
WITH allegations_officers AS (SELECT * FROM data_officer
    INNER JOIN data_officerallegation oa on oa.officer_id = data_officer.id
    INNER JOIN data_allegation da on da.crid = oa.allegation_id
    INNER JOIN data_allegationcategory cat on cat.id = da.most_common_category_id
    WHERE allegation_name = 'Search Of Premise Without Warrant'
    AND location = 'Residence' OR location = 'Apartment' OR location = 'Private Residence'
    OR location = 'Other Private Premise')
SELECT DISTINCT allegations_officers.officer_id AS officer_id, gender, race, appointed_date, rank, active, birth_year, civilian_allegation_percentile, honorable_mention_count, internal_allegation_percentile, trr_count, allegation_count, sustained_count, civilian_compliment_count, current_badge, discipline_count, major_award_count, unsustained_count FROM allegations_officers;

-- Officers not implicated in home invasions
WITH allegations_officers AS (SELECT * FROM data_officer
    INNER JOIN data_officerallegation oa on oa.officer_id = data_officer.id
    INNER JOIN data_allegation da on da.crid = oa.allegation_id
    INNER JOIN data_allegationcategory cat on cat.id = da.most_common_category_id
    WHERE allegation_name != 'Search Of Premise Without Warrant'
    OR allegation_name = 'Search Of Premise Without Warrant'
    AND location != 'Residence' AND location != 'Apartment' AND location != 'Private Residence'
    AND location != 'Other Private Premise')
SELECT DISTINCT allegations_officers.officer_id AS officer_id, gender, race, appointed_date, rank, active, birth_year, civilian_allegation_percentile, honorable_mention_count, internal_allegation_percentile, trr_count, allegation_count, sustained_count, civilian_compliment_count, current_badge, discipline_count, major_award_count, unsustained_count FROM allegations_officers;
