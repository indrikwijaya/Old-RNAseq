import sys
import csv

wiggle_file = sys.argv[1]
output_file = wiggle_file.split("/")[-1].split(".")[0]+"_chrM.sam"

# with open(wiggle_file) as f:
#     wiggle_list = f.read().splitlines()

wiggle_list = [line.rstrip() for line in open(wiggle_file)]
chromM_list = []
index = 0
for i in wiggle_list:
    index += 1
    if i[0] == '@':
        chromM_list.append(i)
    else:
        break
chrom_list = wiggle_list[index:]
chrom_list = list(filter(lambda x: x.split("\t")[2] == 'chrM', chrom_list))
for i in chrom_list:
    chromM_list.append(i)

with open(output_file, "w") as output:
    writer = csv.writer(output, lineterminator='\n')
    for val in chromM_list:
        writer.writerow([val])

# print(chrom_list[:68])
