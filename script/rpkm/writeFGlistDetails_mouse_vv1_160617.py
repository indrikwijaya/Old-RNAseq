import loadCollectionsModule_122710 as lcm
########################################################################
############################################################################
def spliceCDExons(gene):
    cdExons = gene.cdExons()

    sumExonLength = 0
    for exon in cdExons:
        exonLength = exon.len()
        sumExonLength += exonLength
    return sumExonLength

###############################################################################
def sumIntronLengths(gene):
    introns = gene.introns()

    sumIntronLength = 0
    for intron in introns:
        intronLength = intron.len()
        sumIntronLength += intronLength
    return sumIntronLength

############################################################################
def spliceTXExons(gene):
    txExons = gene.txExons()

    sumExonLength = 0
    for exon in txExons:
        exonLength = exon.len()
        sumExonLength += exonLength
    return sumExonLength

###############################################################################
def spliceFpUTR(gene):
##    if gene.fpUtr() == None:
##        fpUTRLength = 0
    if gene.sense() == '+':
        if gene.txLocus().start() == gene.cdLocus().start():
            fpUTRLength = 0
        else:
            fpUTRLength = gene.fpUtr().len()
            for intron in gene.introns():
                if gene.fpUtr().contains(intron):                
                    fpUTRLength -= intron.len()
    elif gene.sense() == '-':
        if gene.txLocus().end() == gene.cdLocus().end():
            fpUTRLength = 0
        else:
            fpUTRLength = gene.fpUtr().len()
            for intron in gene.introns():
                if gene.fpUtr().contains(intron):                
                    fpUTRLength -= intron.len()
    return fpUTRLength

################################################################################
def spliceTpUTR(gene):
##    if gene.tpUtr() == None:
##        tpUTRLength = 0
    if gene.sense() == '+':
        if gene.txLocus().end() == gene.cdLocus().end():
            tpUTRLength = 0
        else:
            tpUTRLength = gene.tpUtr().len()
            for intron in gene.introns():
                if gene.tpUtr().contains(intron):
                    tpUTRLength -= intron.len()
    elif gene.sense() == '-':
        if gene.txLocus().start() == gene.cdLocus().start():
            tpUTRLength = 0
        else:
            tpUTRLength = gene.tpUtr().len()
            for intron in gene.introns():
                if gene.tpUtr().contains(intron):
                    tpUTRLength -= intron.len()
    return tpUTRLength

################################################################################
##########################################################################
##refPath = '/lab/bartel4_ata/huili/refFlats/mouse_refFlats/refFlat_122610.txt'
#refPath = '/home/indrikw/hguo/Documents/annotations/mm9/refFlat/refFlat_160617.txt'
refPath = '/home/indrikw/chrM_genes/refFlat_160617_test.txt'
##splicedGeneORFpath = '/lab/bartel4_ata/huili/refFlats/mouse_refFlats/splicedGenes_ORF_122610.txt'
#splicedGeneORFpath = '/home/indrikw/hguo/Documents/annotations/mm9/refFlat/splicedGenes_ORF_160617.txt'
splicedGeneORFpath = '/home/indrikw/chrM_genes/splicedGenes_ORF_160617.txt'

#chrList = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', 'X', 'Y', 'M']
chrList = ['M']
fgList = lcm.getFilteredGeneList_mouse(refPath, splicedGeneORFpath, chrList)
##############################################################################

outfileString = 'filteredGenesDetails_mouse_160617_1.txt'
outfile = open(outfileString, 'w')
firstLineList = ['GeneName', 'AccNum', 'Chrom', 'mRNALength', 'ORFLength', 'fpUTR_length', 'tpUTR_length', 'sumIntronLengths']
firstLineString = '\t'.join(firstLineList)
outfile.write(firstLineString+'\n')

linesWritten = 1
for gene in fgList:
    mRNAlength = spliceTXExons(gene)
    ORFlength = spliceCDExons(gene)
    fpUTR = spliceFpUTR(gene)
    tpUTR = spliceTpUTR(gene)
    introns = sumIntronLengths(gene)
    outList = [gene.name(), gene.accNum(), gene.chr(), mRNAlength, ORFlength, fpUTR, tpUTR, introns]
    outList = map(lambda i: str(i), outList)
    outListString = '\t'.join(outList)
    outfile.write(outListString+'\n')
    linesWritten += 1
outfile.close()
print 'Number of lines written: ', linesWritten
