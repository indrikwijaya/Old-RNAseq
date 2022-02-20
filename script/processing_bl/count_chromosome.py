import sys
import os

directory = sys.argv[1]

full_dir = os.listdir(directory)
#bl_dir = list(filter(lambda x: x.split(".")[-1] == 'rll', full_dir))
bl_dir = list(filter(lambda x: x.split(".")[-1] == 'bl', full_dir))

lengths = [18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 36]

bl_dir_length = list(filter(lambda x: int(x.split(".")[1]) in lengths, bl_dir))



print(bl_dir)

count_hits = 0
count_reads = 0
count_chrM = 0
count_chrY = 0
count_rRNA = 0
count_otherRNA = 0
count_gene = 0

#for bl in bl_dir_length:
for bl in bl_dir:
    read_input_bl = open(directory + bl)
    genome_bl = read_input_bl.read().split("\n")[:-1]


    genome_bl_chr = list(map(lambda x: x.split("\t"), genome_bl))

    genome_bl_chr_read = list(map(lambda x: int(x[0].split("_")[1]), genome_bl_chr))

    genome_bl_chrM = list(filter(lambda x: x[1] == 'chrM', genome_bl_chr))
    genome_bl_chrM_count = list(map(lambda x: int(x[0].split("_")[1]), genome_bl_chrM))

    genome_bl_chrY = list(filter(lambda x: x[1] == 'chrY', genome_bl_chr))
    genome_bl_chrY_count = list(map(lambda x: int(x[0].split("_")[1]), genome_bl_chrY))

    genome_bl_rRNA = list(filter(lambda x: x[10] == 'rRNA', genome_bl_chr))
    genome_bl_rRNA_count = list(map(lambda x: int(x[0].split("_")[1]), genome_bl_rRNA))

    genome_bl_otherRNA = list(filter(lambda x: x[11] != 'NA', genome_bl_chr))
    genome_bl_otherRNA_count = list(map(lambda x: int(x[0].split("_")[1]), genome_bl_otherRNA))

    genome_bl_gene = list(filter(lambda x: x[10] == 'NA' and x[11] == 'NA' and x[1] != 'chrM' and x[1] != 'chrY', genome_bl_chr))
    genome_bl_gene_count = list(map(lambda x: int(x[0].split("_")[1]), genome_bl_gene))


    count_hits += len(genome_bl)

    count_reads += sum(genome_bl_chr_read)

    #count_chrM += len(genome_bl_chrM)
    count_chrM += sum(genome_bl_chrM_count)

    #count_chrY += len(genome_bl_chrY)
    count_chrY += sum(genome_bl_chrY_count)

    #count_rRNA += len(genome_bl_rRNA)
    count_rRNA += sum(genome_bl_rRNA_count)

    #count_otherRNA += len(genome_bl_other)
    count_otherRNA += sum(genome_bl_otherRNA_count)

    #count_gene += len(genome_bl_gene)
    count_gene += sum(genome_bl_gene_count)


print '======== combined ====================='
print 'Combined number of reads: ', count_reads
print 'Combined number of hits: ', count_hits
print
print 'Combined chrY reads: ', count_chrY
print 'Combined chrM reads: ', count_chrM
print 'Combined otherRNA reads: ', count_otherRNA
print
print 'Combined rRNA reads: ', count_rRNA
print 'Combined potential gene reads: ', count_gene
