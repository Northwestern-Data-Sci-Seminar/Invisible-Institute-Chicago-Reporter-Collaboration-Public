**Before you continue**
Please make sure you know how to connect Tableau to our Postsql database and have the account name and password ready.

There are in total three visualization workbooks, one for salary and one for award.

**Salary Comparison Visualization**
To view the visualization, locate the "Repeaters vs. Offenders Salary.twb" file in the src folder and open it with Tableau. You might need to connect Tableau to CPDB before opening it and enter the account name and password. Once opened, SQL queries will run automatically, please give it a few seconds to run. Then navigate to the data visualization sheet 1 to view the chart of the salary range distribution of Repeaters (those who received the highest amount of complaints) and Offenders (those who received at least one complaint).

**Award Count Comparison Visualization**
To view the visualization, locate the "Repeaters vs. Offenders Awards.twb" file in the src folder and open it with Tableau. You might need to connect Tableau to CPDB before opening it and enter the account name and password. This visualization is based on an imported excel file because we could not connect to the database. If needed, refer to the awards_count.xlsx file for raw data. Once the workbook is opened, navigate to the data visualization sheet 1 to view the chart of the award count range distribution of Repeaters (those who received the highest amount of complaints) and Offenders (those who received at least one complaint).

**Repeater complaints per beat Visualization**
To view this visualization, locate the checkpoint2_repeater_complaints_per_beat.zip file in the src folder, unzip the file and open the .twb file with Tableau. You might need to connect Tableau to CPDB before opening it and enter the account name and password. This visualization is based on aa copied data scource file. You might get a dialogue box when you open the twb file saying, "There was a problem conecting to the data source...". Hit yes, enter the password to database server, go to sheet 2 and click on loacte file on the dialogue box. Here the file you will open is the another file present in the zip folder named, "repeater_complaints.txt". Once you open the file. you should be able to see the map of chicago visualization on sheet 2.