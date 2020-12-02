
-- Question 1
select gender, race, allegation_count, sustained_count, honorable_mention_count, unsustained_count,
       discipline_count, civilian_compliment_count, trr_count, major_award_count, current_salary from data_officer
        where allegation_count is not null
        group by data_officer.id
        order by data_officer.allegation_count desc;


-- Question 2
select race, rank, allegation_count, civilian_compliment_count, current_badge, current_salary, honorable_mention_count, unsustained_count from data_officer
        where current_salary is not null and current_badge is not null
        group by data_officer.id
