import sys, os
#################################################################################################
def getDetails(infileString):
    infile = open(infileString)
    infileLines = infile.readlines()
    infile.close()

    totalReads = 0   ## this includes chrM and chrY !!!!
    rRNAreads = 0
    otherRNAreads = 0

    chrMreads = 0
    chrYreads = 0

    potentialGeneReads = 0

    totalHits = 0   ## this includes chrM and chrY !!!!
    rRNAhits = 0
    otherRNAhits = 0

    chrMhits = 0
    chrYhits = 0

    potentialGeneHits = 0

    for line in infileLines[:-1]:
        line = line.rstrip('\n')
        cols = line.split('\t')

        entryID = cols[0]
        chrom = cols[1]
        rRNAlabel = cols[10]
        otherlabel = cols[11]
        readNum = int(entryID.split('_')[1])

        totalReads += readNum
        totalHits += 1
        if rRNAlabel == 'rRNA':
            rRNAreads += readNum
            rRNAhits += 1
        if otherlabel != 'NA':
            otherRNAreads += readNum
            otherRNAhits +=1

        if chrom == 'chrM':
            chrMreads += readNum
            chrMhits += 1
        if chrom == 'chrY':
            chrYreads += readNum
            chrYhits += 1
        if rRNAlabel == 'NA' and otherlabel == 'NA' and chrom != 'chrM' and chrom != 'chrY':
            ## this hit could potentially be taken for a gene
            potentialGeneReads += readNum
            potentialGeneHits += 1

        return totalReads, rRNAreads, otherRNAreads, chrMreads, chrYreads, potentialGeneReads, totalHits, rRNAhits, otherRNAhits, chrMhits, chrYhits, potentialGeneHits
        #########################################################################################################################


rootdirectory = sys.argv[1]
genomeDirectoryCore = (rootdirectory[:-1].split('/')[-1]) + '_genome/'
genomeDirectory = rootdirectory + genomeDirectoryCore
corefilename_genome = genomeDirectory[:-1].split('/')[-1]

lengths = [18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 36]

dirfiles = os.listdir(genomeDirectory)
avaiLengths = []
for dirfile in dirfiles:
    if dirfile[-3:] == '.bl':
        if int(dirfile.split('.')[-2]) in lengths:
            avaiLengths.append(int(dirfile.split('.')[-2]))

combineReads = 0
combineHits = 0

combineYreads = 0
combineMreads = 0
combinePotentialGeneReads = 0

combineRRNA = 0
combineOTHER = 0

lengthToTotal = {}
lengthTorRNA = {}

## check total number of reads, and total number of uniq reads
for avaiLength in avaiLengths:
    print '============ ' + str(avaiLength) + ' =============='
    ## open file and count readNum, numHits for rRNA
    ## return and add to dict
    filePath = genomeDirectory + corefilename_genome + '.' + str(avaiLength) + '.bl'
    totalReads, rRNAreads, otherRNAreads, chrMreads, chrYreads, potentialGeneReads, totalHits, rRNAhits, otherRNAhits, chrMhits, chrYhits, potentialGeneHits = getDetails(
        filePath)
    print 'Reads: ', totalReads, rRNAreads, otherRNAreads, chrMreads, chrYreads, potentialGeneReads
    print 'Hits: ', totalHits, rRNAhits, otherRNAhits, chrMhits, chrYhits, potentialGeneHits
    combineReads += totalReads
    combineHits += totalHits
    combineYreads += chrYreads
    combineMreads += chrMreads
    combinePotentialGeneReads += potentialGeneReads
    combineRRNA += rRNAreads
    combineOTHER += otherRNAreads
    lengthToTotal[avaiLength] = totalReads
    lengthTorRNA[avaiLength] = rRNAreads

print
print '======== combined ====================='
print 'Combined number of reads ', combineReads
print 'Combined number of hits: ', combineHits
print
print 'Combined chrY reads: ', combineYreads
print 'Combined chrM reads: ', combineMreads
print 'Combined potential gene reads: ', combinePotentialGeneReads
print
print 'Combined rRNA reads ', combineRRNA
print 'Combined otherRNA reads: ', combineOTHER

for length in lengthToTotal:
    print length, lengthToTotal[length], lengthTorRNA[length]