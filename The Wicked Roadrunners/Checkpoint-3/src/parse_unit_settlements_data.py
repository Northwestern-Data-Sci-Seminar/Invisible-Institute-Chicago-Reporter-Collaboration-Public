import csv
unit_settlements = {}
with open('unit_info_settlements.csv', newline='') as csvfile:
    reader = list(csv.reader(csvfile))
    reader = reader[1:]  # remove column headers
    for row in reader:
        unit_id = row[0]
        unit_name = row[1]
        unit_desc = row[2]
        settlement = float(row[3])
        unit_data = (unit_id, unit_name, unit_desc)
        if unit_data in unit_settlements:
            unit_settlements[unit_data] += settlement
        else:
            unit_settlements[unit_data] = settlement
with open('unit_settlements.csv', 'w') as f:
    f.write("%s,%s,%s,%s\n" % ('unit_id', 'unit_name', 'unit_desc', 'total_settlement'))
    for key in unit_settlements.keys():
        f.write("%s,%s,%s,%d\n" % (key[0], key[1], key[2], unit_settlements[key]))

