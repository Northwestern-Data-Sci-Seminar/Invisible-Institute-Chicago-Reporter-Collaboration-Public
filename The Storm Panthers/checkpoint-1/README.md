# Checkpoint 1: SQL Analytics

### How to run our queries

* Clone our directory (in a location you will remember) using `git clone https://github.com/Northwestern-Data-Sci-Seminar/Invisible-Institute-Chicago-Reporter-Collaboration-Public.git`
* Open your terminal, navigate to the directory you just cloned. Then cd into the src folder using `cd 'The Storm Panthers'/checkpoint-1/src`.
* For **q1_a**, un the following command: `psql -f q1_a.sql -h cpdb.cgod7egsd6vr.us-east-2.rds.amazonaws.com -U cpdb-student -d cpdb -p 5432`
    - If you are prompted for a password, enter the following: **dataSci4lyf**
    - If typing the password in doesn't work, try to copy-and-paste it
* Repeat the above steps for each of our questions, replacing **q1_a.sql** with the corresponding file name. Here is a complete list of our SQL files that need to be executed:
    - q_1a
    - q_1b
    - q_2
    - q_3
    - q_4a
    - q_4b
    - q_4c
    - q_5

### Question glossary and expected output

#### q1_a: How many officers who were involved in a “Search Of Premise Without Warrant” are still on the force today, and what proportion of all officers involved in these illegal searches do they constitute?

| count\_active | count\_all | percent\_active |
| :--- | :--- | :--- |
| 4525 | 8499 | 53.24 |



#### q1_b: Are there any officers who’ve been involved in more than one home invasion? What are their IDs and number of illegal searches? How many total repeaters are there?

| number\_of\_repeaters |
| :--- |
| 2569 |

| officer\_id | count |
| :--- | :--- |
| 12478 | 41 |
| 27778 | 39 |
| 17397 | 32 |
| 5913 | 29 |
| 26096 | 29 |
| 25306 | 28 |
| 5193 | 28 |
| 2725 | 28 |
| 11634 | 26 |
| 22828 | 26 |
| 13095 | 26 |
| 18205 | 26 |
| 6678 | 25 |
| 21703 | 24 |
| 19888 | 23 |
| 28280 | 23 |
| 12491 | 23 |
| 28378 | 22 |
| 24521 | 21 |
| 13420 | 21 |
| 21260 | 21 |
| ...  | ... |



#### q2: How many instances of a “Search Of Premise Without Warrant” occurred at someone’s home (Apartment, Other Private Premise, Private Residence, or Residence)? Then, list these allegations and other relevant data (address, incident date, etc).
| home\_invasion\_allegation\_count |
| :--- |
| 2840 |

| allegation\_id | add1 | add2 | city | incident\_date | beat\_id | location |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 296668 |  |  |  | 2004-03-19 00:00:00+00 | 41 | Private Residence |
| 301133 |  |  |  | 2004-10-06 00:00:00+00 | 152 | Private Residence |
| 273077 |  |  |  | 2001-07-15 00:00:00+00 | 160 | Private Residence |
| 292386 |  |  |  | 2003-09-06 00:00:00+00 | 223 | Private Residence |
| 1059519 |  |  |  | 2013-01-15 00:00:00+00 | 133 | Private Residence |
| 296584 |  |  |  | 2004-03-17 00:00:00+00 | 144 | Private Residence |
| 271384 |  |  |  | 2001-05-10 00:00:00+00 | 59 | Private Residence |
| ... | ... | ... | ... | ... | ... | ... |




#### q3: What outcomes have resulted for victims from lawsuits involving a “Home Invasion”?
| outcome | number\_of\_occurences | percent\_of\_total |
| :--- | :--- | :--- |
| Charged | 123 | 45.72 |
| No Outcome Recorded | 118 | 43.87 |
| Hospitalized | 42 | 15.61 |
| Detained | 20 | 7.43 |
| Killed | 6 | 2.23 |


#### **q4_a**: How many Wrong Address allegations have been made?
4 rows
#### **q4_b**: How many Wrong Address allegations led to settlements?
1 row
#### **q4_c**: Are officers involved in Wrong Address allegations linked to related settlements?
18 summaries


#### q5: What outcomes have resulted for officers named in “Search Of Premise Without Warrant” allegations?
| officer\_outcome | number\_of\_occurences | percent\_of\_total |
| :--- | :--- | :--- |
| No Penalty | 24593 | 99.58 |
| Temporary Suspension | 51 | 0.21 |
| Reprimand | 37 | 0.15 |
| Resigned or Removed | 11 | 0.04 |
| Violation Noted | 5 | 0.02 |
