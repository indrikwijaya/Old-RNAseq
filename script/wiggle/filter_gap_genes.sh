#!/bin/bash

lane=$1
#inputDir="/home/indrikw/rnaseq_rep1/lane_${lane}"
inputDir=$2
for i in ATCACG CGATGT TTAGGC CAGATC GATCAG TAGCTT GGCTAC;do
    #cd ${inputDir}/${i}-s_${lane}_1/${i}-s_${lane}_1_genome/
    cd ${inputDir}
    prefix=${i}-s_${lane}_1
    echo $prefix

    bam_chrM=${prefix}"_chrM.bam"
    sam_chrM=${prefix}"_chrM.sam"
    echo $sam_chrM

    sam_gap_chrM=${prefix}"_chrM_gap.txt"
    echo $sam_gap_chrM
    samtools view -h ${bam_chrM} > ${sam_chrM}
    awk '{ if (($4 <=11000) && ($4>=6400)) { print }}' ${sam_chrM} > ${sam_gap_chrM}
    rm ${sam_chrM}
done

samtools view -h ATCACG-s_3_1.bam | awk '{ if($3!='chrM' && $3!='chrUn'){ print $0 } }' | samtools view -Sb - > ATCACG-s_3_1_filter.bam