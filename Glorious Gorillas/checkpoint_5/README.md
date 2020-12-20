{\rtf1\ansi\ansicpg1252\cocoartf1671\cocoasubrtf500
{\fonttbl\f0\fswiss\fcharset0 Helvetica;\f1\fnil\fcharset0 Menlo-Regular;}
{\colortbl;\red255\green255\blue255;\red0\green0\blue0;\red255\green255\blue255;\red0\green0\blue0;
}
{\*\expandedcolortbl;;\cssrgb\c0\c1\c1;\cssrgb\c100000\c100000\c100000\c0;\cssrgb\c0\c0\c0;
}
{\*\listtable{\list\listtemplateid1\listhybrid{\listlevel\levelnfc0\levelnfcn0\leveljc0\leveljcn0\levelfollow0\levelstartat1\levelspace360\levelindent0{\*\levelmarker \{decimal\}.}{\leveltext\leveltemplateid1\'02\'00.;}{\levelnumbers\'01;}\fi-360\li720\lin720 }{\listname ;}\listid1}}
{\*\listoverridetable{\listoverride\listid1\listoverridecount0\ls1}}
\margl1440\margr1440\vieww20040\viewh17800\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf2 \cb3 README.txt\
\
\pard\pardeftab720\partightenfactor0
\cf4 \cb1 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 We had 4 research questions in place to develop our understanding further:\
\pard\tx220\tx720\pardeftab720\li720\fi-720\partightenfactor0
\ls1\ilvl0\cf4 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	1.	}\expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Based on how many years an officer has worked in the force, what the most commonly targeted racial demographic group was per officer, the amount of arrests an officer made, and the race and rank of the officer, to what degree can we accurately predict how many allegations an officer can expect to receive?\uc0\u8232 \
\ls1\ilvl0\kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	2.	}\expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Using the same parameters as question 1 but this time including amount of allegations per officer, to what degree can we accurately predict the most commonly targeted racial demographic group per officer to predict bias?\uc0\u8232 \
\ls1\ilvl0\kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	3.	}\expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Using text analytics, we want to label/categorize documents based on select keywords, and find the total amount of allegations that are labeled as racial slurs to see if we can connect or correlate anything back to our initial approach to find racist officers.\uc0\u8232 \
\ls1\ilvl0\kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	4.	}\expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Of the amount of racial slur allegations found in question 3, how many of them involved weapons or assault? The reason for this is to retrieve more supporting evidence around our initial claims for inherent racism and bias in officers.\cf2 \cb3 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 \
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0
\cf2 \
\
*********\
Questions 1 and 2 are run in the \'91code1.ipynb\'92 script.\
\'91code1.ipynb\'92  is found in checkpoint_5/src\
\
Upon opening, note that you must input the current directory to wherever \
you downloaded the checkpoint_5 folder to. You must input the current directory\
as instructed in the script in the format \'91\'85/checkpoint_5/src\'92\
\
This is because it needs to read csv files which are also housed in the src sub-folder.\
\
\
*Note*: this file is a Jupyter notebook file\
If you don\'92t already have Jupyter notebook installed, run this in your terminal:\
\
\pard\pardeftab720\sl360\partightenfactor0

\f1 \cf2 \expnd0\expndtw0\kerning0
pip install jupyterlab\
\
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0 \cf2 \kerning1\expnd0\expndtw0 After running that, open the Jupyter notebook with this command in your terminal:\
\
\pard\pardeftab720\sl360\partightenfactor0

\f1 \cf2 \expnd0\expndtw0\kerning0
jupyter notebook\
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0 \cf2 \kerning1\expnd0\expndtw0 \
You should now be all set to open and run \'91code1.ipynb\'92 \
\
It is also not necessary to open as our code is all in a Jupyter notebook,\
but if you would like to see the SQL queries we ran to get all of our tables\
it is provided in src folder as \'91Checkpoint5Queries.sql\'92\
*********\
\
*********\
Question 3 and 4: instructions can be found in depth in \'91code2.html\'92\
\
All instructions on how to run can be found there.\
The only pre-requisite is to install spark-nlp for the cluster on data bricks.\
\
Double click on \'91code2.html\'92 to be redirected to the data bricks notebook\
which houses the code we used to answer questions 3 and 4.\
*********}
