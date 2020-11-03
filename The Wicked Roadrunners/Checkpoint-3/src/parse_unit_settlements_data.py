import csv
unit_settlements = {}
with open('unit_settlement_data.csv', newline='') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        unit = row[0]
        settlement = float(row[1])
        if unit in unit_settlements:
            unit_settlements[unit] += settlement
        else:
            unit_settlements[unit] = settlement
csv_columns = ['unit_id', 'total_settlement']
with open('unit_settlements.csv', 'w') as f:
    for key in unit_settlements.keys():
        f.write("%s,%s\n"%(key,unit_settlements[key]))

