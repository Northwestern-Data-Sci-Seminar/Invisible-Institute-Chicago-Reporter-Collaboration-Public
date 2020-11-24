import csv
import string
import pandas as pd
import matplotlib.pyplot as plt
import heapq
from operator import itemgetter

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
        keyword = "".join(filter(lambda char: char in string.printable, r[0]))
        keywords[keyword] = int(r[1])

# manually tag data allegation summaries by summing keyword weights
verbal_abuse = []
verbal_abuse_weight = []
keyword_freq = {}
for s in summaries:
    total_weight = 0  # weight of total keywords found
    for keyword, weight in keywords.items():
        if keyword in s:
            # add weight of found keyword
            total_weight += weight
            # track frequency of keywords across all summaries
            if keyword in keyword_freq:
                keyword_freq[keyword] += 1
            else:
                keyword_freq[keyword] = 1
    if total_weight > 2:
        verbal_abuse.append(1)  # true
        verbal_abuse_weight.append(total_weight)
    else:
        verbal_abuse.append(0)  # false
        verbal_abuse_weight.append(0)

top_keywords = heapq.nlargest(15, keyword_freq.items(), key=itemgetter(1))

# visualize keyword frequencies
plt.title("Top 15 Keyword Frequencies")
plt.bar(*zip(*top_keywords))
labels = [l[0] for l in top_keywords]
plt.xticks(range(len(labels)), labels)
plt.xlabel('Keyword')
plt.ylabel('Frequency')
plt.show()

# add verbal abuse classification to data set
df['verbal_abuse'] = verbal_abuse
df['verbal_abuse_weight'] = verbal_abuse_weight

# drop rows with any NaNs
df = df.dropna()
# export tagged data set to csv
df.to_csv('verbal_abuse.csv', index=True)




