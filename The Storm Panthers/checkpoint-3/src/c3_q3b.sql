-- Select the count of every distinct combination of officer demographics by year
select count(*) as count, gender, race, (year - data_officer.birth_year) as age_at_incident, year
from data_officer
    cross join
    (select year from generate_series(1984,2018) year) year
where ((data_officer.appointed_date is null and year>=birth_year+22) or extract(year from data_officer.appointed_date) <= year)
and ((data_officer.resignation_date is null and year<=birth_year+65) or extract(year from data_officer.resignation_date) >= year)
group by gender, race, age_at_incident, year