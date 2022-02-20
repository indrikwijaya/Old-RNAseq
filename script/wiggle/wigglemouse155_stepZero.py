import sys
#######################################################################
directory = sys.argv[1]
totalMappedReads = float(sys.argv[2])

corefilename = directory[:-1].split('/')[-1]

#chrList = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', 'X', 'Y', 'M']
chrList = ['M']
chrList = map(lambda i: 'chr'+i, chrList)
chromToWigStartToScore = {}
for chrom in chrList:
    chromToWigStartToScore[chrom] = {}
    
#lengths = [18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 36]
lengths = [18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 36]
for length in lengths:
    infileString = directory+corefilename+'.'+str(length)+'.bl'
    infile = open(infileString)
    infileLines = infile.readlines()
    infile.close()

    for line in infileLines[:-1]:
        line = line.rstrip('\n')
        cols = line.split('\t')
        readNum = int(cols[0].split('_')[1])
        chrom = cols[1]
        rawStart = int(cols[8])
        rawEnd = int(cols[9])
        
        if rawStart < rawEnd:
            ## sense is +
            for position in xrange(rawStart, rawEnd+1):
                ## label, make one-based!
                wigStart = position + 1
                if not chromToWigStartToScore[chrom].has_key(wigStart):
                    chromToWigStartToScore[chrom][wigStart] = readNum
                else:
                    chromToWigStartToScore[chrom][wigStart] += readNum
        elif rawStart > rawEnd:
            ## sense is -
            for position in xrange(rawStart, rawEnd-1, -1):
                ## label, make one-based!
                wigStart = position + 1
                if not chromToWigStartToScore[chrom].has_key(wigStart):
                    chromToWigStartToScore[chrom][wigStart] = readNum
                else:
                    chromToWigStartToScore[chrom][wigStart] += readNum

## output
outfileString = 'bigWiggle_'+corefilename+'.wig'
outfile = open(outfileString, 'w')
#header = 'track type=wiggle_0 name=mir155KORNA description=m155_32_RNA visibility=full color=250,150,255 altColor=250,150,255 priority=10'
#secondHeader = 'variableStep chrom='+chromosome+' span=1'
#outfile.write(header+'\n')
#outfile.write(secondHeader+'\n')

for chrom in chromToWigStartToScore:
    secondHeader = 'variableStep chrom='+chrom+' span=1'
    outfile.write(secondHeader+'\n')
    linesWritten = 1
    baseKeys = chromToWigStartToScore[chrom].keys()[:]
    baseKeys.sort()
    for base in baseKeys:
        outList = [str(base)]
        rawScore = chromToWigStartToScore[chrom][base]
        normScore = (rawScore/float(totalMappedReads))*1000000
        outList.append(str(normScore))
        outListString = '\t'.join(outList)
        outfile.write(outListString+'\n')
        linesWritten += 1
    print 'Number of lines written for '+chrom+': ', linesWritten
outfile.close()
