import csv
import string
import pandas as pd

# load in csv data from data_allegation table
file_path = 'data_allegation_summaries.csv'
df = pd.read_csv (file_path)
df = pd.DataFrame(df, columns=['summary', 'rank', 'years_on_force', 'disciplined', 'category', 'allegation_name'])
summaries = df['summary'].to_list()
# rank = df['rank'].to_list()
# years_on_force = df['years_on_force'].to_list()


# load in keywords and their weight (how telling they are of verbal abuse) as dictionary
file_path = 'keywords.csv'
with open(file_path, newline='') as f:
    reader = csv.reader(f)
    reader = list(reader)
    keywords = {}
    for r in reader:
        k = "".join(filter(lambda char: char in string.printable, r[0]))
        keywords[k] = int(r[1])

# manually tag data allegation summaries by summing keyword weights
verbal_abuse = []
verbal_abuse_weight = []
# t = 0 /# true -- verbal abuse found
# f = 0 # false -- verbal abuse not found
for s in summaries:
    count = 0 # weight of total keywords found
    #keys = []
    for k, v in keywords.items():
        if k in s:
            count += v # add weight of found keyword
            #keys.append(k)
    if count > 2:
        verbal_abuse.append(1)  # true
        verbal_abuse_weight.append(count)
        #t += 1
    else:
        verbal_abuse.append(0)  # false
        verbal_abuse_weight.append(0)
        #f += 1

# add verbal abuse classification to data set
df['verbal_abuse'] = verbal_abuse
df['verbal_abuse_weight'] = verbal_abuse_weight
# drop rows with any NaNs
df = df.dropna()
# export tagged data set to csv
df.to_csv('verbal_abuse.csv', index=True)



