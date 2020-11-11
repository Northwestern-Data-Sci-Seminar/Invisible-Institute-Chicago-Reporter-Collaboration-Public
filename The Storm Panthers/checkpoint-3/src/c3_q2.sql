WITH allegations_victims AS (SELECT * FROM data_victim
    INNER JOIN data_allegation da on da.crid = data_victim.allegation_id
    INNER JOIN data_allegationcategory cat on cat.id = da.most_common_category_id
    WHERE allegation_name = 'Search Of Premise Without Warrant'
    AND location = 'Residence' OR location = 'Apartment' OR location = 'Private Residence'
    OR location = 'Other Private Premise')
SELECT DISTINCT allegations_victims.allegation_id AS allegation_id, gender, race FROM allegations_victims;

