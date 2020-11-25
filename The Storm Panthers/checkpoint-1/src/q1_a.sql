/* outputs the number of officers who have a 'Search Of Premise Without Warrant' allegation filed against them who are active on the force */
WITH illegal_searchers_active AS
    (SELECT DISTINCT officer_id as count_active FROM data_allegationcategory
    INNER JOIN data_officerallegation d on data_allegationcategory.id = d.allegation_category_id
    INNER JOIN data_allegation on d.allegation_id = data_allegation.crid
    INNER JOIN data_officer o on d.officer_id = o.id
    WHERE allegation_name = 'Search Of Premise Without Warrant' AND active = 'Yes'),
count_active_all AS
    (SELECT count(count_active) as c_active FROM illegal_searchers_active)
SELECT c_active FROM count_active_all;

/* outputs the number of all officers who have a 'Search Of Premise Without Warrant' allegation filed against them (meaning their status is either active, not active, or unknown */
WITH illegal_searchers_all AS
    (SELECT DISTINCT officer_id as count_all FROM data_allegationcategory
    INNER JOIN data_officerallegation d on data_allegationcategory.id = d.allegation_category_id
    INNER JOIN data_allegation on d.allegation_id = data_allegation.crid
    INNER JOIN data_officer o on d.officer_id = o.id
    WHERE allegation_name = 'Search Of Premise Without Warrant'),
count_active_all AS
    (SELECT count(count_all) as c_all FROM illegal_searchers_all)
SELECT c_all FROM count_active_all;
