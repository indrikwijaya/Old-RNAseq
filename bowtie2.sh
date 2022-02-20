#!/bin/bash
lane=$1
index_dir='/home/indrikw/bowtie2_test/index/mm10/mm10'
working_dir='/home/indrikw/bowtie2_test_v2/rnaseq_rep2/'
rna_dir='/home/indrikw/bowtie2_test/rnaseq_rep2/rawFiles/'

for day in ATCACG CGATGT TTAGGC CAGATC GATCAG TAGCTT GGCTAC; do
    cd ${working_dir}lane_${lane}/${day}-s_${lane}_1/${day}-s_${lane}_1_genome/
    pwd

    echo gunzip ${rna_dir}${day}-s_${lane}_1_sequence.txt.gz
    echo python /home/indrikw/script/processing_fastq/checkQualityMark_v3_indrik.py ${rna_dir}${day}-s_${lane}_1_sequence.txt ${day}

    #inputFile=${inputDir}$day-s_${lane}_1/$day-s_${lane}_1_genome/adapTrim_${day}_sequence.txt

    inputFile=adapTrim_${day}_sequence.txt
    echo $inputFile

    #output=$(echo $inputFile | cut -d'/' -f 1)
    output=${inputFile##*/}
    output=$(echo $output | cut -d'_' -f 2)
    output=$(echo $output-s_${lane}_1)
    echo ${output}

    echo rm triage_${day}_sequence.txt

    output_sam=${output}".sam"
    output_un=${output}"Un.txt"

    output_bam=${output}".bam"
    output_sort_bam=${output}".sort"
    output_sort_bam_index=${output}".sort.bam"
    #echo $output_sort_bam_index

    output_chrM_bam=${output}"_chrM.bam"
    output_chrM_wig=${output}"_chrM.wig"

    echo bowtie2 \
    -x ${index_dir} \
    --phred64 \
    --sensitive-local \
    -k 1 \
    -p 8 \
    ${inputFile} \
    -S ${output_sam} \
    --un ${output_un}

    echo rm ${inputFile}
    echo rm ${output_un}

    echo Rscript --vanilla ${working_dir}calc_rpkm.R ${output_sam} ${output}

    echo rm ${output_sam}
    echo rm ${rna_dir}${day}-s_${lane}_1_sequence.txt

    # preprocess sam files into bam files & generate chrM files
    samtools view -bS ${output_sam} > ${output_bam}
    samtools sort ${output_bam} ${output_sort_bam}
    samtools index ${output_sort_bam_index}
    samtools view -b ${output_sort_bam} chrM > ${output_chrM_bam}

    samtools mpileup ${output_chrM_bam} | perl -ne 'BEGIN{print "track type=wiggle_0 name=$output description=$output autoScale=off viewLimits=0:8000\n"};($c, $start, undef, $depth) = split; if ($c ne $lastC) { print "variableStep chrom=$c\n"; }; $lastC=$c;next unless $. % 1 ==0;print "$start\t$depth\n";' > ${output_chrM_wig}
done