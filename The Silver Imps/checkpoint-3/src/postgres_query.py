#!/usr/bin/env python
# coding: utf-8

# In[4]:


import psycopg2
import sys


# In[7]:


conn = psycopg2.connect(
    host="localhost",
    database="cpdb",
    user="cloudsqladmin",
    )
cur = conn.cursor()


# In[8]:




s = "select dd.id, dd.race, dd.birth_year, xx.ct from data_officer dd, (select distinct officer_id, count(allegation_id) as ct from ( select distinct data_officerallegation.disciplined, data_officerallegation.allegation_id, data_officerallegation.officer_id from data_officerallegation, (select * from data_allegation where is_officer_complaint is false and incident_date is not null and cast(incident_date as date) >= '07-15-2014' and cast(incident_date as date) < '07-15-2018') timespan1 where data_officerallegation.allegation_id = timespan1.crid) timespan1oa group by officer_id order by ct desc limit 557)xx where xx.officer_id = dd.id"
sql = "COPY ({0}) TO STDOUT WITH CSV HEADER".format(s)
with open("repeater14-18.csv", "w") as file:
    cur.copy_expert(sql, file)
conn.close()


# In[ ]:




