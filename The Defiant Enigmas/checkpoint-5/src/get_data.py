import pandas as pd
import psycopg2

def get_data():
    db_host = "cpdb.cgod7egsd6vr.us-east-2.rds.amazonaws.com"
    db_user = "cpdb-student"
    db_password = "dataSci4lyf"
    db_name = "cpdb"

    connection = psycopg2.connect(host = db_host,  
                                user = db_user, 
                                password = db_password, 
                                dbname = db_name)

    sql_query = "select data_allegation.crid, \
                        data_allegation.summary, \
                        data_allegation.coaccused_count, \
                        max(data_allegationcategory.category) most_common_category, \
                        bool_or(case when data_officerallegation.final_finding = 'SU' then true else false end) sustained, \
                        count(males.gender) male_officers, \
                        count(females.gender) female_officers, \
                        count(white_hispanic.race) white_hispanic_officers, \
                        count(asian_pacific.race) asian_pacific_officers, \
                        count(hispanic.race) hispanic_officers, \
                        count(white.race) white_officers, \
                        count(native_american.race) native_american_officers, \
                        count(black.race) black_officers, \
                        avg(data_officer.birth_year) average_birth_year, \
                        avg((case when data_officer.resignation_date is null then current_date else data_officer.resignation_date end) - data_officer.appointed_date) average_career_length_days, \
                        avg(data_officer.allegation_count)  average_allegation_count, \
                        avg(data_officer.honorable_mention_count) average_honorable_mention_count, \
                        avg(data_officer.major_award_count) average_major_award_count, \
                        avg(data_officer.sustained_count) average_sustained_count, \
                        avg(data_officer.trr_count) average_use_of_force_count, \
                        avg(data_officer.discipline_count) average_discipline_count, \
                        avg(data_officer.civilian_compliment_count) average_civilian_compliment_count \
                from data_allegation \
                left join data_officerallegation on data_officerallegation.allegation_id = data_allegation.crid \
                left join data_allegationcategory on data_allegation.most_common_category_id = data_allegationcategory.id \
                left join data_officer on data_officer.id = data_officerallegation.officer_id \
                left join data_officer males on data_officer.id = males.id and males.gender = 'M' \
                left join data_officer females on data_officer.id = females.id and females.gender = 'F' \
                left join data_officer white_hispanic on data_officer.id = white_hispanic.id and white_hispanic.race = 'White Hispanic' \
                left join data_officer asian_pacific on data_officer.id = asian_pacific.id and asian_pacific.race in ('Asian/Pacific', 'Asian/Pacific Islander') \
                left join data_officer hispanic on data_officer.id = hispanic.id and hispanic.race = 'Hispanic' \
                left join data_officer white on data_officer.id = white.id and white.race = 'White' \
                left join data_officer native_american on data_officer.id = native_american.id and native_american.race in ('Native American/Alaskan Native', 'Amer Ind/Alaskan Native') \
                left join data_officer black on data_officer.id = black.id and black.race = 'Black' \
                where data_allegation.summary != '' \
                group by data_allegation.crid;"

    print('Retreiveing data...')
    return pd.read_sql(sql_query, con=connection)
