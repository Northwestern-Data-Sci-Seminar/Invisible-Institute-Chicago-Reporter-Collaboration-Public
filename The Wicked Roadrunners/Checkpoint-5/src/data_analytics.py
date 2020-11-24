import pandas as pd
import matplotlib.pyplot as plt
from textwrap import wrap

# load in data set
df = pd.read_csv('verbal_abuse.csv')
texts = df['summary'].astype(str)
ranks = df['rank'].astype(str)
years_on_force = df['years_on_force'].astype(int)
y = df['verbal_abuse']
weighted = df['verbal_abuse_weight']


# plot data to get better understanding of verbal abuse and other police characteristics

# *** RANK ***
rank_counts = ranks.value_counts()
distinct_ranks = list(rank_counts.keys())
verbal_abuse_by_rank = {}

# get total number of counts of verbal abuse by rank
for (r, v) in zip(ranks, y):
    if r in verbal_abuse_by_rank:
        verbal_abuse_by_rank[r] += v
    else:
        verbal_abuse_by_rank[r] = v

# normalize counts of verbal abuse by rank since some ranks are more popular than others
for key, val in verbal_abuse_by_rank.items():
    verbal_abuse_by_rank[key] = val / rank_counts[key]


plt.title("Rank and Verbal Abuse")
plt.bar(*zip(*verbal_abuse_by_rank.items()))
labels = ['\n'.join(wrap(l, 8)) for l in distinct_ranks]
plt.xticks(range(len(distinct_ranks)), labels)
plt.xlabel('Rank')
plt.ylabel('Likelihood of verbal abuse')
plt.show()

# *** YEARS ON FORCE ***

plt.title("Seniority and Verbal Abuse")
plt.scatter(years_on_force, weighted)
plt.xlabel('Years on Force')
plt.ylabel('Severity of verbal abuse')
plt.show()






