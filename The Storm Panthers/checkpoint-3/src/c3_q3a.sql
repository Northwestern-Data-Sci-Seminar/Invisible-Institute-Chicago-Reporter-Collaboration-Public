-- Extract officer allegation info for home invasion incidents
select data_officer.id, gender, race, (extract(YEAR from start_date) - data_officer.birth_year) as age_at_incident,
       extract(Year from start_date) as incident_year
from data_allegation
    inner join data_officerallegation on data_allegation.crid = data_officerallegation.allegation_id
    inner join data_officer on data_officerallegation.officer_id = data_officer.id
    inner join
    (select distinct data_allegation.crid
        from data_allegation
            inner join data_officerallegation on data_allegation.crid = data_officerallegation.allegation_id
            inner join data_allegationcategory on data_officerallegation.allegation_category_id = data_allegationcategory.id
        where
            data_allegationcategory.allegation_name = 'Search Of Premise Without Warrant'
            and (location = 'Residence' or location = 'Apartment' or location = 'Private Residence' or location = 'Other Private Premise'
                    or location = 'XX' or location = '' or location is Null)
    ) allegations on allegations.crid = data_allegation.crid