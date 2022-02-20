#!/bin/c
rpkm_dir="/home/indrikw/rpkm_test"

#inputDir="/home/indrikw/rpf_rep1"
inputDir=$1 #/home/indrikw/bowtie2_test/rnaseq_rep1

input=$2 #genome or refseq

for lane in 4; do #4 5
    #go to lane directory

    #cd /home/indrikw/bowtie2_test/rnaseq/lane_${lane}
    cd ${inputDir}/lane_${lane}
    pwd #/home/indrikw/rnaseq_data/lane_3

    for day in ATCACG CGATGT TTAGGC CAGATC GATCAG TAGCTT GGCTAC; do #ATCACG CGATGT TTAGGC CAGATC GATCAG TAGCTT GGCTAC
        #go to day directory
        mkdir ${day}-s_${lane}_1/
        cd ${inputDir}/lane_${lane}/${day}-s_${lane}_1/

        pwd

            DIRECTORY="${day}-s_${lane}_1_"$2
            if [ ! -d "$DIRECTORY" ]; then
                echo mkdir ${day}-s_${lane}_1_$2
                mkdir ${day}-s_${lane}_1_$2
                #ATCACG-s_2_1_genome or ATCACG-s_2_1_refseq
            fi

            #go to genome/refseq directory
            cd ${day}-s_${lane}_1_$2
            pwd #/home/indrikw/rnaseq_data/lane_3/ATCACG-s_3_1/ATCACG-s_3_1_genome

            #run scripts
                #file="/home/indrikw/lane_${lane}/${day}-s_${lane}_1_sequence.txt"
                file=${inpuDir}"/lane_${lane}/${day}-s_${lane}_1_sequence.txt"
                #create masterFile
                solexaFile=/home/indrikw/${day}-s_${lane}_1/${day}-s_${lane}_1_$2.solexa
                dqt='"'
                {
                    echo "solexaFile=${dqt}${solexaFile}${dqt}"
                    #echo 'nibDirectory = "/home/hguo/Downloads/Mus_musculus/UCSC/mm9/Sequence/Chromosomes/nibDirectory/"'
                    echo 'nibDirectory = "/home/indrikw/bowtie2_test/fa_files/nibDirectory/"'
                } >masterFile.txt
                mv masterFile.txt masterFile.py

                #echo $file
                currdir=$(pwd)
                if [ $2 = "genome" ]; then
                    echo sh "/home/indrikw/rnaseq_rep/lane_${lane}/fast_to_rpkm.sh" $file $day $currdir $rpkm_dir $lane
                    #sh "/home/indrikw/rnaseq_rep/lane_${lane}/fast_to_rpkm.sh" $file $day $currdir $rpkm_dir $lane | tee output_${day}_${lane}.txt

                    sh ${inputDir}"/sam_to_rpkm.sh" $day $lane $currdir | tee output_${day}_${lane}.txt
                else
                    echo sh "/home/indrikw/refseq_processing.sh" $file $day $currdir $rpkm_dir $lane
                    #sh "/home/indrikw/refseq_processing.sh" $file $day $currdir $rpkm_dir $lane | tee output_${day}_${lane}.txt
                fi

        #return to lane directory
        #cd /home/indrikw/rpf_data/lane_${lane}
        #cd /home/indrikw/rnaseq_rep/lane_${lane}
        #cd /data/indrikw/rnaseq_data/lane_${lane}
        #cd /home/indrikw/bowtie2_test/rnaseq/lane_${lane}
        cd ${inputDir}/lane_${lane}
        pwd #/home/indrikw/rnaseq_data/lane_3
        done

    done