- Temporary table of average allegations per year for a unit
drop table if exists temp_unitallegationcount;
​
create temp table temp_unitallegationcount as
select unit_id, count(allegation_id) as num_allegations
from data_officerallegation left join data_officerhistory
on data_officerallegation.officer_id = data_officerhistory.officer_id
group by unit_id;
​
​
-- Mean and sd of allegations per unit
drop table if exists avg_allegations_per_unit;
drop table if exists sd_allegations_per_unit;
create temp table avg_allegations_per_unit as select avg(num_allegations) from temp_unitallegationcount;
create temp table sd_allegations_per_unit as select |/ avg((num_allegations - (select avg(num_allegations) from temp_unitallegationcount)) ^ 2) from temp_unitallegationcount;
​
-- Table for average num of allegations per year
drop table if exists temp_officerallegationsperyear;
​
create temp table temp_officerallegationsperyear as select data_officer.id, (cast(count(data_officerallegation.id) as float) / cast((date_part('year',(resignation_date)) - date_part('year',(appointed_date))) as float)) as allegations_per_year
from data_officerallegation right join data_officer
on data_officerallegation.officer_id = data_officer.id
where appointed_date is not null and resignation_date is not null and (date_part('year',(resignation_date)) - date_part('year',(appointed_date))) > 0
group by data_officer.id;
​
​
-- Mean and sd of officer allegations per year
drop table if exists avg_officer_allegations_per_year;
drop table if exists sd_officer_allegations_per_year;
create temp table avg_officer_allegations_per_year as select avg(allegations_per_year) from temp_officerallegationsperyear;
create temp table sd_officer_allegations_per_year as select |/ avg((allegations_per_year - (select avg(allegations_per_year) from temp_officerallegationsperyear)) ^ 2) from temp_officerallegationsperyear;
​
-- Table for allegations for officer in specific unit
drop table if exists temp_unitofficerallegationsperyear;
​
create temp table temp_unitofficerallegationsperyear as select data_officerhistory.officer_id, data_officerhistory.unit_id, (count(data_officerallegation.id) / cast((date_part('year',(data_officerhistory.end_date)) - date_part('year',(data_officerhistory.effective_date))) as float)) as allegations_per_unit_year
from data_officerhistory inner join data_officerallegation on data_officerhistory.officer_id = data_officerallegation.officer_id and data_officerallegation.start_date between data_officerhistory.effective_date and data_officerhistory.end_date
where data_officerhistory.effective_date is not null and data_officerhistory.end_date is not null and (date_part('year',(data_officerhistory.end_date)) - date_part('year',(data_officerhistory.effective_date))) > 0
group by data_officerhistory.officer_id, data_officerhistory.unit_id, data_officerhistory.end_date, data_officerhistory.effective_date
order by data_officerhistory.officer_id;
​
​
-- Compare officer allegations for the units they were in
select temp_unitofficerallegationsperyear.officer_id, temp_unitofficerallegationsperyear.unit_id, (allegations_per_unit_year - (select * from avg_officer_allegations_per_year)) / (select * from sd_officer_allegations_per_year) as officer_allegations_per_year_z_score, (num_allegations - (select * from avg_allegations_per_unit)) / (select * from sd_allegations_per_unit) as unit_allegations_per_year_z_score
from (temp_unitofficerallegationsperyear join temp_unitallegationcount on temp_unitallegationcount.unit_id = temp_unitofficerallegationsperyear.unit_id) join temp_officerallegationsperyear on temp_officerallegationsperyear.id = temp_unitofficerallegationsperyear.officer_id
group by temp_unitofficerallegationsperyear.officer_id, temp_unitofficerallegationsperyear.unit_id, temp_unitofficerallegationsperyear.allegations_per_unit_year, temp_unitallegationcount.num_allegations;
