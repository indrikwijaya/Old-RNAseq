#############################################################
## need to change this file, to only take in one argument
## the bl file, and nothing else
## length etc, move to one file above
################################################################

import os, sys, time
import utilityModule as um
##############################################################################3
def success(jobid):
    subcommand = 'bjobs '+str(jobid)
    j = os.popen(subcommand)
    handle = j.read().split()
    status = handle[10]
    return status

#############################################################################
def makeSplitfiles(infileLines, outfileString, numSplitfiles):

    splitfileNames = []
    for i in range(numSplitfiles):
        splitfileString = outfileString[:-3]+'.'+str(i)+'.bl'
        splitfileNames.append(splitfileString)

    splitfile = open(splitfileNames[0], 'w')
    index = 0
    count = 0
    for line in infileLines:
        splitfile.write(line)
        count += 1
        if count == 20000:
            splitfile.write('# blasting completed')
            splitfile.close()
            index += 1
            splitfile = open(splitfileNames[index], 'w')
            count = 0
    splitfile.write('# blasting completed')
    splitfile.close()
    return splitfileNames
################################################################################

## lines per file: 20000

## argument: queryBLfilename

#queryFilePath, queue = sys.argv[1], sys.argv[2] ## queryFilePath includes directory
queryFilePath = sys.argv[1]
#directory = '/lab/bartel/huili/Databases/hg18/'
directory = '/home/hguo/Downloads/Mus_musculus/UCSC/mm9/Sequence/Chromosomes/nibDirectory/'

lastSlash = queryFilePath.rfind('/')
inDirectory = queryFilePath[:lastSlash]

infile = open(queryFilePath)
infileLines = infile.readlines()
infile.close()

outfileString = queryFilePath[:-3]+'.fa'
outfile = open(outfileString, 'w')


linesWritten = 0
for line in infileLines[:-1]:
    line = line.rstrip('\n')
    cols = line.split('\t')
    key = cols[0]
    chrom = cols[1]
    length = cols[3]
    rawStart = int(cols[8])
    rawEnd = int(cols[9])
    if rawStart < rawEnd:
        sense = '+'
    elif rawStart > rawEnd:
        sense = '-'

    hitLocus = um.Locus(chrom, rawStart, rawEnd, sense)
    hitSeq = um.getSequence(hitLocus, directory)
    header = '>'+key
    package = header+'\n'+hitSeq
    outfile.write(package+'\n')
    linesWritten += 2
outfile.close()
print '======= '+outfileString+' ============'
print 'Number of linesWritten: ', linesWritten
print

# numLines = len(infileLines[:-1])
# if numLines <= 20000:
#     needToSplit = False
# else:
#     needToSplit = True



# if not needToSplit:
#     linesWritten = 0
#     for line in infileLines[:-1]:
#         line = line.rstrip('\n')
#         cols = line.split('\t')
#         key = cols[0]
#         chrom = cols[1]
#         length = cols[3]
#         rawStart = int(cols[8])
#         rawEnd = int(cols[9])
#         if rawStart < rawEnd:
#             sense = '+'
#         elif rawStart > rawEnd:
#             sense = '-'
#
#         hitLocus = um.Locus(chrom, rawStart, rawEnd, sense)
#         hitSeq = um.getSequence(hitLocus, directory)
#         header = '>'+key
#         package = header+'\n'+hitSeq
#         outfile.write(package+'\n')
#         linesWritten += 2
#     outfile.close()
#     print '======= '+outfileString+' ============'
#     print 'Number of linesWritten: ', linesWritten
#     print

# else:
#     print '======= '+outfileString+' ============'
#     print '======= needs splitting =============='
#     numSplitfiles = numLines/20000
#     if numLines%20000 != 0:
#         ## there is a remainder
#         numSplitfiles += 1
#     splitfileList = makeSplitfiles(infileLines[:-1], outfileString, numSplitfiles)
#     print 'Number of splitBLfiles made: ', len(splitfileList)
#     ## return a list of filenames, files already split
#     jobIDs = []
#     for sf in splitfileList:
#         command = 'bsub -o /dev/null -q '+queue+' python convertBL_mouse.py '+sf+' '+queue
#         a = os.popen(command)
#         print command
#         b = a.read().split(' ')
#         a.close()
#         jobid = b[1][1:-1]
#         jobIDs.append(jobid)
#     print '========== List of jobIDs ================='
#     print jobIDs
#     print '============================================'
#
#     statusTracks = []
#     triggerCombine = False
#     while triggerCombine == False:
#         time.sleep(30)
#         for job in jobIDs:
#             status = success(job)
#             #print status
#             statusTracks.append(status)
#             #print statusTracks
#         if statusTracks.count('DONE') == numSplitfiles:
#             triggerCombine = True
#         statusTracks = []
#
#     if triggerCombine:
#         ## ie all the splitBLfiles have been converted to .fa files
#         ## combfileString = outfileString from beginning
#
#         resultfileList = map(lambda i: i[:-3]+'.fa', splitfileList)
#         outlines = 0
#         for rf in resultfileList:
#             resultSplitfile = open(rf)
#             resultLines = resultSplitfile.readlines()
#             resultSplitfile.close()
#
#             for rline in resultLines:
#                 outfile.write(rline)
#                 outlines += 1
#         outfile.close()
#         print '======= '+outfileString+' ============'
#         print 'Number of outlinesWritten: ', outlines
#         print
#
#         ## delete resultsplitfiles
#         for rf in resultfileList:
#             os.remove(rf)
#         ## delete splitfiles
#         for sf in splitfileList:
#             os.remove(sf)


