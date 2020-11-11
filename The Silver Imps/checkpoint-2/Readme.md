Data Science Seminar - The Silver Imps

Song Luo, Jing Jiang, Yuxin Chen

# Checkpoint 2: Data Visualization
## Questions

Question 1: Using our definition of “repeaters” above, what percentage of total complaints are they responsible for?

Question 2: What is the demographic information (race, age and sex) of the “repeaters” using our definition above?

Question 3: What is the distribution of the categories of the misconducts (illegal search, use of force, etc.) for those “repeaters” we defined above?

Question 4: Among the allegations against the “repeaters”, what percentage of these cases lead to the “repeaters” being disciplined in 2006-2010, 2010-2014, 2014-2018 respectively?


## Setup
1. Install the updated version of Tableau. The version we use is 2020.3.
2. Install the updated version of postsql driver. The version we use is 12.0.
3. Connect shared AWS instance of database by following configuration:
			hostname: cpdb.cgod7egsd6vr.us-east-2.rds.amazonaws.com
			database: cpdb
			user: cpdb-student
			password: dataSci4lyf

## How to run the code
We use Tableau as our setup to run and test the code. Once you connect the database, click "New Custom SQL" button on the right lower conner of the data source page. The box poped up is where you need to enter the SQL queries.


### Q1
After you create custom sql for different time span. You should see three tables where each contains two columns like this:
| total | case_of_repeater | 
  xxx			xxx

Then open a new sheet by clicking the "+" button on the bottom. Drag each column in three tables (total of 2*3 = 6) to the column and you should see Sum for each one e.g. Sum(total(Custom SQL)).　Then click Showme and select horizontal bars, where you should see a plot just like figure 1. 
To generate the percentage graph, you need to select total & case_of_repeater attributes in the same folder, and right click to select create Calculated Field. In the field creation box, enter Sum(total(your custom sql name here)) / Sum(case_of_repeater(your custom sql name here)). Repeate this process for each table, and then you should have three calculated field. Drag them all into the column and choose the horizontal bar graph again.

### Q2
Again, enter the sql query for each timespan. You will get three tables where each one should look like this:
| officer_id | age_range | race | gender
     xxx          xxxx      xx      x

In the new sheet page, select count(age_range), count(race), count(gender) to the row, and select packed bubbles. Note we only deal with one table on each sheet, and combine three sheets together in the dashboard.
Open a new sheet, select count(age_range), count(race), count(gender) to the row agian, and select horizontal bar graph.

### Q3 
Enter the sql query for each timespan. You will get three tables where each one should look like this:
| category | totalct | 
    xxx		   xxx
For each sheet, drag category to the column and count to the row, and combine three sheets together in the dashboard.

### Q4
Enter the sql query for each timespan. You will get three tables where each one should look like this:
| count | disciplined | 
    xxx		  xxx
Drag disciplined to the rows and all counts to the columns (we combine all data in one sheet), then select horizontal bar graph.
Drag disciplined to the rows and all counts to the columns (we combine all data in one sheet), then select stacked bar graph.