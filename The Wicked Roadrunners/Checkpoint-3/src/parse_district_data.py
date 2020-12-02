import csv
districts = {} #key - district
yearly_data = {} #key - year, value = [count, discipline count]

with open('Result_1.csv') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    line_count = 0
    for row in csv_reader:
        district = int(row[0]) - 1
        year = int(row[1][:4])
        disciplined = row[2]
        disciplined_count = 0
        if disciplined == 'true':
            disciplined_count = 1
        if district in districts:
            if year in districts[district]:
                districts[district][year][0] += 1
                districts[district][year][1] += disciplined_count
            else:
                districts[district][year] = [1, disciplined_count]
        else:
            districts[district] = {year: [1, disciplined_count]}

for district in districts.keys():
    for year in districts[district].keys():
        ratio = 100 * (districts[district][year][1] / districts[district][year][0])
        districts[district][year] = ratio
    districts[district] = sorted(districts[district].items())
    
csv_columns = ['district', 'year', 'ratio']
csv_file = 'district_data_cleaned.csv'
with open(csv_file, 'w') as f:
    writer = csv.DictWriter(f, fieldnames=csv_columns)
    writer.writeheader()
    for district in districts.keys():
        for t in districts[district]:
            year = t[0]
            ratio = t[1]
            f.write("%s, %d, %.2f\n" % (district, year, ratio))



