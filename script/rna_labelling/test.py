import otherRNALabel_mouse as otherRNA
import ncRNAoverlapKeys_mouse as ro
import utilityModule as um
import


rrnaKeys = ro.getKeys(directory, length, rnaType)
collatedKey = chrom+'('+sense+'):'+str(rawStart)+'_'+str(length)
    if collatedKey in rrnaKeys:
        cols[10] = rnaType

def findrRNA(repeatLocus, rnaType):
    return repeatLocus.repClass() == rnaType


def getKeys(directory, wantedLength, rnaType):
    print time.asctime()
    rrnaCollection = ai.getRmskRepeats('mm9', lambda repeatLocus: findrRNA(repeatLocus, rnaType))
    print time.asctime()
    print 'Number of loci in ' + rnaType + ' collection: ', len(rrnaCollection)
    print

    length = int(wantedLength)
    lenTuple = (length, length + 1)
    datasets = [directory]
    requirementTrue = lambda i: True

    genomic_hits = um.getAllGenomicHits(datasets, lenTuple, requirementTrue, requirementTrue)
    print 'Number of genomic hits loaded: ', len(genomic_hits)

    # def getAllGenomicHits(listOfDatasets, lenRange, requirementGS, requirementGH):
    #     genomicSpecies = getAllGenomicSpecies(listOfDatasets, lenRange, requirementGS)

        # def getAllGenomicSpecies(directoryList, lenRange, requirement=lambda gs: True):
        #     seqToGs = dict()
        #     for directory in directoryList:
        #         localGS = getGenomicSpecies(directory, lenRange, requirement)

                # gets all of the blast results from a directory.  returns a dictionary
                # whose keys are sequences with blast matches to the genome, and values
                # are lists of loci.

                # def getGenomicSpecies(directory, lenRange, requirement):
                #     if directory[-1] != '/': directory += '/'
                #     # raises an exception if blasting is not complete for a directory
                #     ### directoryBlastValidate(directory,lenRange)
                #     ### i put this test in the parseBlast function, which will
                #     ### raise an exception if any of the files aren't there or aren't done.
                #
                #     gsList = []
                #     # get the names of all the blast files
                #     blastFilenames = getBlastResultFiles(directory, lenRange)
                #     for bf in blastFilenames: gsList.extend(parseBlasts(bf, requirement))
                #
                #     return gsList

                # this function gets the blast result files from a directory without getting
                # any of the supporting blast result files.
                # def getBlastResultFiles(directoryName, lenRange):
                #     allFilenames = os.listdir(directoryName)
                #     queryFiles = getBlastQueryFiles(directoryName, lenRange)
                #     blastResultFiles = []
                #     for qf in queryFiles:
                #         noDirQf = qf.split('/')[-1]
                #         noDirRf = noDirQf[:-3] + '.bl'
                #         if allFilenames.count(noDirRf) == 1: blastResultFiles.append(qf[:-3] + '.bl')
                #     return blastResultFiles

                # this function gets the primary query files (one file per directory per query length)
                # def getBlastQueryFiles(directoryName, rangeTuple=False):
                #     # import the contents of the masterFile
                #     master = getMaster(directoryName)
                #
                #     # get the names of all the query files
                #     coreFilename = '.'.join(master['solexaFile'].split('.')[:-1])
                #     coreFilename = coreFilename.split('/')[-1]
                #     allFilenames = os.listdir(directoryName)
                #
                #     queryFiles = []
                #     for fn in allFilenames:
                #         fnSplit = fn.split('.')
                #         # since I don't know that the input will have the appropriate length or
                #         # that the portion of the name in the length position will resolve to
                #         # an integer, I put those checks within a try statement, with addition to
                #         # the query list at the end.
                #         try:
                #             ### first, check the name format (corename . integer . fa)
                #             if fnSplit[-1] == 'fa' and \
                #                             '.'.join(fnSplit[:-2]) == coreFilename and \
                #                             int(fnSplit[-2]) > 0:
                #                 ### if appropriate, check the rangeTuple
                #                 if not (rangeTuple) or rangeTuple[0] <= int(fnSplit[-2]) < rangeTuple[1]:
                #                     queryFiles.append(fn)
                #         except:
                #             pass
                #
                #     queryFiles = map(lambda i: directoryName + i, queryFiles)
                #     return queryFiles

                # def getMaster(directory):
                #     if directory[-1] != '/': directory += '/'
                #     masterFileName = directory + 'masterFile.py'
                #     return getEnvironment(masterFileName)

                # getEnvironment
                # returns the environment of the indicated file after interpretation
                # by the python interpreter
                # def getEnvironment(filename):
                #     sandbox = dict()
                #     file = open(filename)
                #     text = file.read()
                #     file.close()
                #     exec text in sandbox
                #     return sandbox
        # genomicHits = makeGenomicHits(genomicSpecies, requirementGH)

        # def makeGenomicHits(gsList, requirement=lambda gh: True):
        #     hitList = []
        #     for gs in gsList:
        #         for gh in gs.hits():
        #             if requirement(gh): hitList.append(gh)
        #     return hitList
        # return genomicHits

            for gs in localGS:
                seq = gs.seq()
                if seqToGs.has_key(seq):
                    readNum = gs.readNum() + seqToGs[seq].readNum()
                    loci = gs.hits()
                    loci.extend(seqToGs[seq].hits())
                    seqToGs[seq] = GenomicSpecies(Species(seq, readNum), loci)
                else:
                    seqToGs[seq] = gs
            print directory, len(seqToGs)
        return seqToGs.values()

    genomicHits = um.LocusCollection(genomic_hits, 1000)
    print 'Number of hits in genomicHits collection: ', len(genomicHits)
    print '========================================'

    rrna_hits = []
    for locus in rrnaCollection.getLoci():
        hits = genomicHits.getOverlap(locus, sense='sense')
        rrna_hits.extend(hits)
    rrnaHitsCollection = um.LocusCollection(rrna_hits, 1000)
    print 'Number of ' + rnaType + ' hits in collection: ', len(rrnaHitsCollection)
    print '========================================'

    rrnaKeys = []
    readsFromrrna = 0
    for hit in rrnaHitsCollection.getLoci():
        chrom = hit.chr()
        length = hit.len()
        sense = hit.sense()
        if sense == '+':
            rawStart = hit.start()
        elif sense == '-':
            rawStart = hit.end()
        collatedKey = chrom + '(' + sense + '):' + str(rawStart) + '_' + str(length)
        rrnaKeys.append(collatedKey)
        readsFromrrna += hit.readNum()

    print 'Number of reads from ' + rnaType + ' hits: ', readsFromrrna
    return rrnaKeys


def getRmskRepeats(assembly, myFilter=lambda rl: True, winSize=10000):
    if assembly == 'mm8':
        repeatDirectory = '/lab/bartel/ruby/Solexa/databases/mm8/annotations/Rmsk/'
    elif assembly == 'hg18':
        repeatDirectory = '/lab/bartel1_ata/ruby/Solexa/databases/hg18/Annotation/Rmsk/'
    elif assembly == 'ce4':
        repeatDirectory = '/lab/bartel/ruby/Solexa/databases/ce4/Annotations/Rmsk/'
    elif assembly == 'mm9':
        repeatDirectory = '/home/hguo/Documents/annotations/mm9/Rmsk/'
    else:
        raise ValueError("assembly '" + assembly + "' isn't valid.")
    allRmskFiles = map(lambda f: repeatDirectory + f, os.listdir(repeatDirectory))

    repeatCollection = utilityModule.LocusCollection([], winSize)
    for rmskFilename in allRmskFiles:
        print rmskFilename
        rmskFile = open(rmskFilename)
        lineNum = 0
        for line in rmskFile.readlines():
            lineNum += 1
            if line[-1] == '\n': line = line[:-1]
            cols = line.split()
            # check for the correct number of columns
            if len(cols) != 17: raise ValueError(
                "Line " + str(lineNum) + " in " + rmskFilename + " is incorrect:\n'" + line + "'")
            localLocus = utilityModule.Locus(cols[5], int(cols[6]), (int(cols[7]) - 1), cols[9])
            localRepeat = RepeatLocus(localLocus, cols[10], cols[11], cols[12], int(cols[13]), int(cols[14]))
            if myFilter(localRepeat): repeatCollection.append(localRepeat)
        rmskFile.close()

    return repeatCollection


