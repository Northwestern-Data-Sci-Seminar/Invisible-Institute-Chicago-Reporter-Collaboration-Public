-- Temporary table for civilian allegations useful for all questions
drop table if exists temp_data_officerallegation_civilian;

create temp table temp_data_officerallegation_civilian as
select data_officerallegation.id, data_officerallegation.officer_id, incident_date
from data_officerallegation
    left join data_allegation
        on data_officerallegation.allegation_id = data_allegation.crid
where not data_allegation.is_officer_complaint;

/* MISCONDUCT LEVEL FOR EACH OFFICER */

-- Temporary table for officer allegations per year
drop table if exists temp_officerallegationsperyear;

create temp table temp_officerallegationsperyear as
select data_officer.id,
       (cast(count(temp_data_officerallegation_civilian.id) as float) / ((extract(epoch from ((resignation_date + interval '1 hour') - (appointed_date + interval '1 hour'))) / (60*60*24*365)))) as allegations_per_year
from temp_data_officerallegation_civilian
    right join data_officer
    on temp_data_officerallegation_civilian.officer_id = data_officer.id
where appointed_date is not null and resignation_date is not null and (date_part('year',(resignation_date)) - date_part('year',(appointed_date))) > 0
group by data_officer.id;

-- Mean and sd of officer allegations per year
drop table if exists avg_officer_allegations_per_year;
drop table if exists sd_officer_allegations_per_year;
create temp table avg_officer_allegations_per_year as
    select avg(allegations_per_year) from temp_officerallegationsperyear;
create temp table sd_officer_allegations_per_year as
    select |/ avg((allegations_per_year - (select avg(allegations_per_year) from temp_officerallegationsperyear)) ^ 2) from temp_officerallegationsperyear;

-- Output values
select * from avg_officer_allegations_per_year;
select * from sd_officer_allegations_per_year;

/* MISCONDUCT LEVEL FOR UNITS */

-- Temporary table for unit and num officers in the unit
drop table if exists temp_unitcount;

create temp table temp_unitcount as
select unit_id, count(unit_id) as unit_count
from data_officerhistory
group by unit_id
order by unit_id;

-- Temporary table for allegation count per unit
drop table if exists temp_unitallegationcount;

create temp table temp_unitallegationcount as
select data_officerhistory.unit_id,
       count(temp_data_officerallegation_civilian.id) as allegation_count,
       max(date_part('year',data_officerhistory.end_date)) as max_year,
       min(date_part('year',data_officerhistory.effective_date)) as min_year,
       unit_count
from temp_data_officerallegation_civilian
    left join data_officerhistory
        on temp_data_officerallegation_civilian.officer_id = data_officerhistory.officer_id
    left join temp_unitcount
        on temp_unitcount.unit_id = data_officerhistory.unit_id
group by data_officerhistory.unit_id, unit_count;

-- Temporary table of average allegations per year for a unit
drop table if exists temp_unitallegationperyear;

create temp table temp_unitallegationperyear as
select unit_id, allegation_count / ((max_year - min_year) * unit_count) as avg_allegation_per_year
from temp_unitallegationcount
where max_year - min_year > 0;


-- Table for allegations for officer in specific unit
drop table if exists temp_unitofficerallegationsperyear;

create temp table temp_unitofficerallegationsperyear as
select data_officerhistory.officer_id, data_officerhistory.unit_id,
       (count(temp_data_officerallegation_civilian.id) / ((extract(epoch from ((data_officerhistory.end_date + interval '1 hour') - (data_officerhistory.effective_date + interval '1 hour'))) / (60*60*24*365)))) as allegations_per_unit_year
from data_officerhistory
    left join temp_data_officerallegation_civilian
        on data_officerhistory.officer_id = temp_data_officerallegation_civilian.officer_id
               and temp_data_officerallegation_civilian.incident_date between data_officerhistory.effective_date and data_officerhistory.end_date
where data_officerhistory.effective_date is not null and data_officerhistory.end_date is not null and (date_part('year',(data_officerhistory.end_date)) - date_part('year',(data_officerhistory.effective_date))) > 0
group by data_officerhistory.officer_id, data_officerhistory.unit_id, data_officerhistory.end_date, data_officerhistory.effective_date
order by data_officerhistory.officer_id;

-- Compute average and sd for units based on above table
drop table if exists unit_allegation_distribution;
create temp table unit_allegation_distribution as
select unit_id, avg(allegations_per_unit_year) as avg, |/ variance(allegations_per_unit_year) as sd
from temp_unitofficerallegationsperyear where unit_id < 26 group by unit_id;

-- Average mean and sd of allegations per unit per year
drop table if exists avg_avg_allegations_per_unit;
drop table if exists avg_sd_allegations_per_unit;
create temp table avg_avg_allegations_per_unit as select avg(avg) from unit_allegation_distribution;
create temp table avg_sd_allegations_per_unit as select avg(sd) from unit_allegation_distribution;

-- Output values
select * from avg_avg_allegations_per_unit;
select * from avg_sd_allegations_per_unit;

-- Temp Table to compare officer allegations for the units they were in
drop table if exists temp_unitofficerallegations_zscores;

create temp table temp_unitofficerallegations_zscores as
select temp_unitofficerallegationsperyear.officer_id,
       temp_unitofficerallegationsperyear.unit_id,
       (allegations_per_unit_year - (select * from avg_officer_allegations_per_year)) / (select * from sd_officer_allegations_per_year) as officer_allegations_per_year_z_score,
       (temp_unitallegationperyear.avg_allegation_per_year - (select * from avg_avg_allegations_per_unit)) / (select * from avg_sd_allegations_per_unit) as unit_allegations_per_year_z_score
from (temp_unitofficerallegationsperyear
    join temp_unitallegationperyear
        on temp_unitallegationperyear.unit_id = temp_unitofficerallegationsperyear.unit_id)
    join temp_officerallegationsperyear
        on temp_officerallegationsperyear.id = temp_unitofficerallegationsperyear.officer_id
group by temp_unitofficerallegationsperyear.officer_id,
         temp_unitofficerallegationsperyear.unit_id,
         temp_unitofficerallegationsperyear.allegations_per_unit_year,
         temp_unitallegationperyear.avg_allegation_per_year;

-- View z-scores results for question 3 and 4 (unit_id 0-25 corresponds to the 25 districts in Chicago)
select * from temp_unitofficerallegations_zscores where unit_id < 26;

/* QUESTION 2 */

-- Temporary table for change in officer allegation count
drop table if exists temp_unitofficerallegations_change;

create temp table temp_unitofficerallegations_change as
select officer_id, unit_id, officer_allegations_per_year_z_score - lag(officer_allegations_per_year_z_score) over (partition by officer_id order by officer_id) as officer_allegations_rate_change
from temp_unitofficerallegations_zscores where unit_id < 26;

-- Mean and sd of change in officer allegations when they change a unit
select avg(officer_allegations_rate_change) from temp_unitofficerallegations_change;

/* MISCONDUCT LEVEL FOR BEATS */

-- Temp table to create association between officer and beat/watch
drop table if exists temp_officerbeatwatch;

create temp table temp_officerbeatwatch as
select officer_id, beat, watch, min(shift_start) as first_shift, max(shift_end) as last_shift
from data_officerassignmentattendance
    join (select * from data_area where area_type='beat') as data_beatarea
        on data_officerassignmentattendance.beat=data_beatarea.name
group by officer_id, beat, watch;

-- Temp table to get officer count per beat and watch
drop table if exists temp_beatwatchcount;

create temp table temp_beatwatchcount as
select beat, watch, count(beat)
from temp_officerbeatwatch
group by beat, watch
order by beat, watch;

-- Table for allegations for officer in specific beat watch (modify based on time in beat watch to get proper representation)
drop table if exists temp_beatwatchofficerallegationsperyear;

create temp table temp_beatwatchofficerallegationsperyear as
select temp_officerbeatwatch.officer_id, temp_officerbeatwatch.beat, temp_officerbeatwatch.watch, cast(count(temp_data_officerallegation_civilian.id) as float) as allegation_count,
       (extract(epoch from (temp_officerbeatwatch.last_shift - temp_officerbeatwatch.first_shift)) / (60*60*24*365)) as years,
       cast(count(temp_data_officerallegation_civilian.id) as float) / (extract(epoch from (temp_officerbeatwatch.last_shift - temp_officerbeatwatch.first_shift)) / (60*60*24*365)) as allegations_per_year
from temp_officerbeatwatch
    left join temp_data_officerallegation_civilian
        on temp_officerbeatwatch.officer_id = temp_data_officerallegation_civilian.officer_id
               and temp_data_officerallegation_civilian.incident_date between temp_officerbeatwatch.first_shift and temp_officerbeatwatch.last_shift
where (extract(epoch from (temp_officerbeatwatch.last_shift - temp_officerbeatwatch.first_shift)) / (60*60*24*365)) > 0.5
group by temp_officerbeatwatch.officer_id,
         temp_officerbeatwatch.beat,
         temp_officerbeatwatch.watch,
         temp_officerbeatwatch.last_shift,
         temp_officerbeatwatch.first_shift
order by temp_officerbeatwatch.officer_id;

-- Get the distribution of level of misconduct for each beat and watch and each beat only
drop table if exists temp_beatwatch_allegation_distribution;

create temp table temp_beatwatch_allegation_distribution as
select beat, watch, avg(allegations_per_year) as avg, |/ variance(allegations_per_year) as sd
from temp_beatwatchofficerallegationsperyear
group by beat, watch;

drop table if exists temp_beat_allegation_distribution;

create temp table temp_beat_allegation_distribution as
select beat, avg(allegations_per_year) as avg, |/ variance(allegations_per_year) as sd
from temp_beatwatchofficerallegationsperyear
group by beat;

-- Mean and sd of allegations per beat per year
drop table if exists avg_avg_allegations_per_beat;
drop table if exists avg_sd_allegations_per_beat;
create temp table avg_avg_allegations_per_beat as select avg(avg) from temp_beat_allegation_distribution;
create temp table avg_sd_allegations_per_beat as select avg(sd) from temp_beat_allegation_distribution;

-- Output values
select * from avg_avg_allegations_per_beat;
select * from avg_sd_allegations_per_beat;

-- Mean and sd of allegations per beat and watch per year
drop table if exists avg_avg_allegations_per_beatwatch;
drop table if exists avg_sd_allegations_per_beatwatch;
create temp table avg_avg_allegations_per_beatwatch as select avg(avg) from temp_beatwatch_allegation_distribution;
create temp table avg_sd_allegations_per_beatwatch as select avg(sd) from temp_beatwatch_allegation_distribution;

-- Output values
select * from avg_avg_allegations_per_beatwatch;
select * from avg_sd_allegations_per_beatwatch;

/* MISCONDUCT LEVEL FOR CREWS */
-- DOING THIS IS A PROBLEM BECAUSE WE DO NOT KNOW THE TIME AN OFFICER WAS IN THE CREW
/*
select officer_id, member_count
       from (data_officercrew
            left join data_crew
                on data_officercrew.crew_id=data_crew.id) as crew_members
            left join temp_officerallegationsperyear
                on crew_members.officer_id=temp_officerallegationsperyear.id;
limit 10;
*/

/* ALLEGATION TYPE DISTRIBUTION PER UNIT, BEAT, and CREW */

-- Allegation type per officer
drop table if exists temp_officer_allegation_type;

create temp table temp_officer_allegation_type as
select officer_id, category, allegation_name
from (data_officerallegation
    left join data_allegationcategory
        on data_officerallegation.allegation_category_id=data_allegationcategory.id) as dc1
    join data_allegation on data_allegation.crid = dc1.allegation_id
        where not data_allegation.is_officer_complaint;

-- Allegations type per unit
drop table if exists temp_types_of_allegation_unit;
create temp table temp_types_of_allegation_unit as
select unit_id, category, allegation_name
from data_officerhistory
    left join temp_officer_allegation_type
        on data_officerhistory.officer_id=temp_officer_allegation_type.officer_id;

drop table if exists temp_unit_allegation_category;
create temp table temp_unit_allegation_category as
select unit_id, category, count(category)
from temp_types_of_allegation_unit where unit_id < 26 group by unit_id, category;

drop table if exists temp_unit_allegation_distribution;
create temp table temp_unit_allegation_distribution as
select unit_id,
       sum(case when category='Bribery / Official Corruption' then count else 0 end) as Bribery_Official_Corruption,
       sum(case when category='Racial Profiling' then count else 0 end) as Racial_Profiling,
       sum(case when category='Conduct Unbecoming (Off-Duty)' then count else 0 end) as Conduct_Unbecoming_Off_Duty,
       sum(case when category='Criminal Misconduct' then count else 0 end) as Criminal_Misconduct,
       sum(case when category='False Arrest' then count else 0 end) as False_Arrest,
       sum(case when category='Operation/Personnel Violations' then count else 0 end) as Operation_Personnel_Violations,
       sum(case when category='Excessive Force' then count else 0 end) as Excessive_Force,
       sum(case when category='Domestic' then count else 0 end) as Domestic,
       sum(case when category='Use Of Force' then count else 0 end) as Use_Of_Force,
       sum(case when category='Money / Property' then count else 0 end) as Money_Property,
       sum(case when category='Supervisory Responsibilities' then count else 0 end) as Supervisory_Responsibilities,
       sum(case when category='Traffic' then count else 0 end) as Traffic,
       sum(case when category='Incident' then count else 0 end) as Incident,
       sum(case when category='Illegal Search' then count else 0 end) as Illegal_Search,
       sum(case when category='Medical' then count else 0 end) as Medical,
       sum(case when category='Lockup Procedures' then count else 0 end) as Lockup_Procedures,
       sum(case when category='Unknown' then count else 0 end) as Unknown,
       sum(case when category='First Amendment' then count else 0 end) as First_Amendment,
       sum(case when category='Verbal Abuse' then count else 0 end) as Verbal_Abuse,
       sum(case when category='Drug / Alcohol Abuse' then count else 0 end) as Drug_Alcohol_Abuse
       from temp_unit_allegation_category group by unit_id;

-- Compute GINI impurity for each unit
drop table if exists temp_unit_allegation_distribution_total;
create temp table temp_unit_allegation_distribution_total as
select *, Bribery_Official_Corruption+Racial_Profiling+Conduct_Unbecoming_Off_Duty
                +Criminal_Misconduct+False_Arrest+Operation_Personnel_Violations
                +Excessive_Force+Domestic+Use_Of_Force+Money_Property
                +Supervisory_Responsibilities+Traffic+Incident+Illegal_Search
                +Medical+Lockup_Procedures+Unknown+First_Amendment+Verbal_Abuse+Drug_Alcohol_Abuse
                as total
from temp_unit_allegation_distribution;

drop table if exists temp_unit_allegation_distribution_gini;
create temp table temp_unit_allegation_distribution_gini as
select unit_id, 1-(Bribery_Official_Corruption/total)^2
        -(Racial_Profiling/total)^2
        -(Conduct_Unbecoming_Off_Duty/total)^2
        -(Criminal_Misconduct/total)^2
        -(False_Arrest/total)^2
        -(Operation_Personnel_Violations/total)^2
        -(Excessive_Force/total)^2
        -(Domestic/total)^2
        -(Use_Of_Force/total)^2
        -(Money_Property/total)^2
        -(Supervisory_Responsibilities/total)^2
        -(Traffic/total)^2
        -(Incident/total)^2
        -(Illegal_Search/total)^2
        -(Medical/total)^2
        -(Lockup_Procedures/total)^2
        -(Unknown/total)^2
        -(First_Amendment/total)^2
        -(Verbal_Abuse/total)^2
        -(Drug_Alcohol_Abuse/total)^2
                as gini
from temp_unit_allegation_distribution_total;

select avg(gini) from temp_unit_allegation_distribution_gini;



-- Allegations type per beat
drop table if exists temp_types_of_allegation_beat;
create temp table temp_types_of_allegation_beat as
select beat, category, allegation_name
from temp_officerbeatwatch
    left join temp_officer_allegation_type
        on temp_officerbeatwatch.officer_id=temp_officer_allegation_type.officer_id;


drop table if exists temp_beat_allegation_category;
create temp table temp_beat_allegation_category as
select beat, category, count(category)
from temp_types_of_allegation_beat group by beat, category;

drop table if exists temp_beat_allegation_distribution;
create temp table temp_beat_allegation_distribution as
select beat,
       sum(case when category='Bribery / Official Corruption' then count else 0 end) as Bribery_Official_Corruption,
       sum(case when category='Racial Profiling' then count else 0 end) as Racial_Profiling,
       sum(case when category='Conduct Unbecoming (Off-Duty)' then count else 0 end) as Conduct_Unbecoming_Off_Duty,
       sum(case when category='Criminal Misconduct' then count else 0 end) as Criminal_Misconduct,
       sum(case when category='False Arrest' then count else 0 end) as False_Arrest,
       sum(case when category='Operation/Personnel Violations' then count else 0 end) as Operation_Personnel_Violations,
       sum(case when category='Excessive Force' then count else 0 end) as Excessive_Force,
       sum(case when category='Domestic' then count else 0 end) as Domestic,
       sum(case when category='Use Of Force' then count else 0 end) as Use_Of_Force,
       sum(case when category='Money / Property' then count else 0 end) as Money_Property,
       sum(case when category='Supervisory Responsibilities' then count else 0 end) as Supervisory_Responsibilities,
       sum(case when category='Traffic' then count else 0 end) as Traffic,
       sum(case when category='Incident' then count else 0 end) as Incident,
       sum(case when category='Illegal Search' then count else 0 end) as Illegal_Search,
       sum(case when category='Medical' then count else 0 end) as Medical,
       sum(case when category='Lockup Procedures' then count else 0 end) as Lockup_Procedures,
       sum(case when category='Unknown' then count else 0 end) as Unknown,
       sum(case when category='First Amendment' then count else 0 end) as First_Amendment,
       sum(case when category='Verbal Abuse' then count else 0 end) as Verbal_Abuse,
       sum(case when category='Drug / Alcohol Abuse' then count else 0 end) as Drug_Alcohol_Abuse
       from temp_beat_allegation_category group by beat;

-- Compute GINI impurity for each beat
drop table if exists temp_beat_allegation_distribution_total;
create temp table temp_beat_allegation_distribution_total as
select *, Bribery_Official_Corruption+Racial_Profiling+Conduct_Unbecoming_Off_Duty
                +Criminal_Misconduct+False_Arrest+Operation_Personnel_Violations
                +Excessive_Force+Domestic+Use_Of_Force+Money_Property
                +Supervisory_Responsibilities+Traffic+Incident+Illegal_Search
                +Medical+Lockup_Procedures+Unknown+First_Amendment+Verbal_Abuse+Drug_Alcohol_Abuse
                as total
from temp_beat_allegation_distribution;

drop table if exists temp_beat_allegation_distribution_gini;
create temp table temp_beat_allegation_distribution_gini as
select beat, 1-(Bribery_Official_Corruption/total)^2
        -(Racial_Profiling/total)^2
        -(Conduct_Unbecoming_Off_Duty/total)^2
        -(Criminal_Misconduct/total)^2
        -(False_Arrest/total)^2
        -(Operation_Personnel_Violations/total)^2
        -(Excessive_Force/total)^2
        -(Domestic/total)^2
        -(Use_Of_Force/total)^2
        -(Money_Property/total)^2
        -(Supervisory_Responsibilities/total)^2
        -(Traffic/total)^2
        -(Incident/total)^2
        -(Illegal_Search/total)^2
        -(Medical/total)^2
        -(Lockup_Procedures/total)^2
        -(Unknown/total)^2
        -(First_Amendment/total)^2
        -(Verbal_Abuse/total)^2
        -(Drug_Alcohol_Abuse/total)^2
                as gini
from temp_beat_allegation_distribution_total where total > 0;

select avg(gini) from temp_beat_allegation_distribution_gini;




-- Allegations type per crew
drop table if exists temp_types_of_allegation_crew;
create temp table temp_types_of_allegation_crew as
select crew_id, category, allegation_name
from data_officercrew
    left join temp_officer_allegation_type
        on data_officercrew.officer_id=temp_officer_allegation_type.officer_id;

drop table if exists temp_crew_allegation_category;
create temp table temp_crew_allegation_category as
select crew_id, category, count(category)
from temp_types_of_allegation_crew group by crew_id, category;

drop table if exists temp_crew_allegation_distribution;
create temp table temp_crew_allegation_distribution as
select crew_id,
       sum(case when category='Bribery / Official Corruption' then count else 0 end) as Bribery_Official_Corruption,
       sum(case when category='Racial Profiling' then count else 0 end) as Racial_Profiling,
       sum(case when category='Conduct Unbecoming (Off-Duty)' then count else 0 end) as Conduct_Unbecoming_Off_Duty,
       sum(case when category='Criminal Misconduct' then count else 0 end) as Criminal_Misconduct,
       sum(case when category='False Arrest' then count else 0 end) as False_Arrest,
       sum(case when category='Operation/Personnel Violations' then count else 0 end) as Operation_Personnel_Violations,
       sum(case when category='Excessive Force' then count else 0 end) as Excessive_Force,
       sum(case when category='Domestic' then count else 0 end) as Domestic,
       sum(case when category='Use Of Force' then count else 0 end) as Use_Of_Force,
       sum(case when category='Money / Property' then count else 0 end) as Money_Property,
       sum(case when category='Supervisory Responsibilities' then count else 0 end) as Supervisory_Responsibilities,
       sum(case when category='Traffic' then count else 0 end) as Traffic,
       sum(case when category='Incident' then count else 0 end) as Incident,
       sum(case when category='Illegal Search' then count else 0 end) as Illegal_Search,
       sum(case when category='Medical' then count else 0 end) as Medical,
       sum(case when category='Lockup Procedures' then count else 0 end) as Lockup_Procedures,
       sum(case when category='Unknown' then count else 0 end) as Unknown,
       sum(case when category='First Amendment' then count else 0 end) as First_Amendment,
       sum(case when category='Verbal Abuse' then count else 0 end) as Verbal_Abuse,
       sum(case when category='Drug / Alcohol Abuse' then count else 0 end) as Drug_Alcohol_Abuse
       from temp_crew_allegation_category where crew_id is not null group by crew_id;

-- Compute GINI impurity for each crew
drop table if exists temp_crew_allegation_distribution_total;
create temp table temp_crew_allegation_distribution_total as
select *, Bribery_Official_Corruption+Racial_Profiling+Conduct_Unbecoming_Off_Duty
                +Criminal_Misconduct+False_Arrest+Operation_Personnel_Violations
                +Excessive_Force+Domestic+Use_Of_Force+Money_Property
                +Supervisory_Responsibilities+Traffic+Incident+Illegal_Search
                +Medical+Lockup_Procedures+Unknown+First_Amendment+Verbal_Abuse+Drug_Alcohol_Abuse
                as total
from temp_crew_allegation_distribution;

drop table if exists temp_crew_allegation_distribution_gini;
create temp table temp_crew_allegation_distribution_gini as
select crew_id, 1-(Bribery_Official_Corruption/total)^2
        -(Racial_Profiling/total)^2
        -(Conduct_Unbecoming_Off_Duty/total)^2
        -(Criminal_Misconduct/total)^2
        -(False_Arrest/total)^2
        -(Operation_Personnel_Violations/total)^2
        -(Excessive_Force/total)^2
        -(Domestic/total)^2
        -(Use_Of_Force/total)^2
        -(Money_Property/total)^2
        -(Supervisory_Responsibilities/total)^2
        -(Traffic/total)^2
        -(Incident/total)^2
        -(Illegal_Search/total)^2
        -(Medical/total)^2
        -(Lockup_Procedures/total)^2
        -(Unknown/total)^2
        -(First_Amendment/total)^2
        -(Verbal_Abuse/total)^2
        -(Drug_Alcohol_Abuse/total)^2
                as gini
from temp_crew_allegation_distribution_total where total > 0;

select avg(gini) from temp_crew_allegation_distribution_gini;
