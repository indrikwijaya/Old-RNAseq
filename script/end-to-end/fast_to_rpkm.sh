#!/bin/bash

export PATH=$PATH:/home/indrikw/ucsc_tools/executables/
rootDir=$1
day=$2
label=$(echo $rootDir | tr '/' '\n' | tail -2)
index_genome=${label}_genome
index_refseq=${label}_refseq

currDir_genome=${rootDir}${index_genome}
currDir_refseq=${rootDir}${index_refseq}

cd ${currDir_genome}
pwd
gunzip ${label}_sequence.txt.gz

genome_index_dir='/home/hguo/Documents/indexes/mm9/m_musculus_genome'
refseq_index_dir="/home/hguo/Documents/indexes/mm9/refseq/m_musculus_refseq"

#Check whether all inputs and variables are correct
echo $rootDir $day $index_genome $currDir_genome $index_refseq $currDir_refseq

############################################
#CheckQuality FASTQ
############################################
#input = directory with fastq file, $FASTQ_DIR
echo python /home/indrikw/script/processing_fastq/checkQualityMark_v3_indrik.py $currDir_genome/ $label
python /home/indrikw/script/processing_fastq/checkQualityMark_v3_indrik.py $currDir_genome/ $label
#output = adapTrim_sample_sequence.txt, triage_sample_sequence.txt
rm ${label}_sequence.txt

############################################
#BOWTIE (genome)
############################################
#n = 0
#input = adapTrim_sample_sequence.txt
echo bowtie --phred64-quals -n 0 -l 29 -e 200 -k 1 -m 1 -p 16 ${genome_index_dir} adapTrim_${label}_sequence.txt ${index_genome}_zeroMM.map --un ${index_genome}_zeroUn.txt
bowtie --phred64-quals -n 0 -l 29 -e 200 -k 1 -m 1 -p 4 ${genome_index_dir} adapTrim_${label}_sequence.txt ${index_genome}_zeroMM.map --un ${index_genome}_zeroUn.txt
#output = _zeroMM.map, _zeroUn.txt
rm adapTrim_${label}_sequence.txt
rm ${index_genome}_zeroMM.map

#n = 1
#input = _zeroUn.txt
echo bowtie --phred64-quals -n 1 -l 29 -e 200 -k 1 -m 1 -p 16 ${genome_index_dir} ${index_genome}_zeroUn.txt ${index_genome}_oneMM.map --un ${index_genome}_oneUn.txt
bowtie --phred64-quals -n 1 -l 29 -e 200 -k 1 -m 1 -p 4 ${genome_index_dir} ${index_genome}_zeroUn.txt ${index_genome}_oneMM.map --un ${index_genome}_oneUn.txt
#output = _oneMM.map, _oneUn.txt
rm ${index_genome}_zeroUn.txt
rm ${index_genome}_oneMM.map

#n = 2
#input = _oneUn.txt
echo bowtie --phred64-quals -n 2 -l 29 -e 200 -y -k 1 -m 1 -p 16 ${genome_index_dir} ${index_genome}_oneUn.txt ${index_genome}_twoMM.map --max ${index_genome}_twoMax.txt --un ${index_genome}_twoUn.txt
bowtie --phred64-quals -n 2 -l 29 -e 200 -y -k 1 -m 1 -p 4 ${genome_index_dir} ${index_genome}_oneUn.txt ${index_genome}_twoMM.map --max ${index_genome}_twoMax.txt --un ${index_genome}_twoUn.txt
#output = _twoMM.map, _twoUn.txt
rm ${index_genome}_oneUn.txt
rm ${index_genome}_twoMax.txt
rm ${index_genome}_twoMM.map

############################################
#BOWTIE (refseq)
############################################
cd ${currDir_refseq}
pwd
#n = 0
#input = _twoUn.txt
echo bowtie --phred64-quals -n 0 -l 29 -e 200 -k 1 -m 1 -p 24 ${refseq_index_dir} ${rootDir}${label}_genome/${label}_genome_twoUn.txt ${index_refseq}_zeroMM.map --un ${index_refseq}_zeroUn.txt
bowtie --phred64-quals -n 0 -l 29 -e 200 -k 1 -m 1 -p24 ${refseq_index_dir} ${rootDir}${label}_genome/${label}_genome_twoUn.txt ${index_refseq}_zeroMM.map --un ${index_refseq}_zeroUn.txt
#output = _refseq_zeroUn.txt

#n = 1
#input = _refseq_zeroUn.txt
echo bowtie --phred64-quals -n 1 -l 29 -e 200 -k 1 -m 1 -p 24 ${refseq_index_dir} ${index_refseq}_zeroUn.txt ${index_refseq}_oneMM.map --un ${index_refseq}_oneUn.txt
bowtie --phred64-quals -n 1 -l 29 -e 200 -k 1 -m 1 -p24 ${refseq_index_dir} ${index_refseq}_zeroUn.txt ${index_refseq}_oneMM.map --un ${index_refseq}_oneUn.txt
#output = _refseq_oneUn.txt
rm ${index_refseq}_zeroUn.txt

#n= 2
#input = _refseq_oneUn.txt
echo bowtie --phred64-quals -n 2 -l 29 -e 200 -y -k 1 -m 1 -p 24 ${refseq_index_dir} ${index_refseq}_oneUn.txt ${index_refseq}_twoMM.map --max ${index_refseq}_twoMax.txt --un ${index_refseq}_twoUn.txt
bowtie --phred64-quals -n 2 -l 29 -e 200 -y -k 1 -m 1 -p 24 ${refseq_index_dir} ${index_refseq}_oneUn.txt ${index_refseq}_twoMM.map --max ${index_refseq}_twoMax.txt --un ${index_refseq}_twoUn.txt
#output = _refseq_twoUn.txt
rm ${index_refseq}_oneUn.txt
rm ${index_refseq}_twoUn.txt

#############################################
#Generate BL files
#############################################
#input = directory that contains _zeroMM.map, _oneMM.map, _twoMM.map
#script = alignParse_v8_mouse.py
#echo python /home/indrikw/script/processing_bl/alignParse_v8_mouse_indrik.py $currDir/
#python /home/indrikw/script/processing_bl/alignParse_v8_mouse_indrik.py $currDir/
#output = unlabelled bl files

#Create extra directory just for checking fadict process, current folder already contains processed bl files
mkdir ${index_refseq}
cd ${index_refseq}
#############################################
#faDict process
#############################################
#input = _refseq_zeroMM.map, _refseq_oneMM.map, _refseq_twoMM.map
#script = faDict_v7_mouse.py
echo python /home/indrikw/script/processing_refseq/faDict_v7_mouse.py $currDir_refseq/
python /home/indrikw/script/processing_refseq/faDict_v7_mouse.py $currDir_refseq/
#output = _refseq.x.bl
rm *map

#############################################
#blbed2 process
#############################################
#input = _refseq.x.bl
#script = annotateBed_v7_mouse.py
echo python /home/indrikw/processing_refseq/annotateBed_v7_mouse.py $currDir/
#python /home/indrikw/processing_refseq/annotateBed_v7_mouse.py $currDir/
#output = _refseq.x.blbed2

#############################################
#Generate masterFile
#############################################

#solexaFile=$currDir/${index}.solexa
#dqt='"'
#{
#echo "solexaFile=${dqt}${solexaFile}${dqt}"
#echo 'nibDirectory = "/home/hguo/Downloads/Homo_sapiens/UCSC/hg19/Sequence/Chromosomes/nibDirectory/"'
#} >masterFile.txt
#mv masterFile.txt masterFile.py

#############################################
#Generate FA files
#############################################
#input = directory with bl files
#script = convertBL_mouse.py

#for i in $(seq 18 1 36);do echo python /home/indrikw/script/rna_labelling/convertBL_mouse.py ${index}.${i}.bl; done
#for i in $(seq 18 1 36);do python /home/indrikw/script/rna_labelling/convertBL_mouse.py ${index}.${i}.bl;done

#for i in $(seq 18 1 36);do echo python /home/indrikw/script/rna_labelling/convertBL_mouse_subprocess.py ${currDir}/${index}.${i}.bl;done
#for i in $(seq 18 1 36);do python /home/indrikw/script/rna_labelling/convertBL_mouse_subprocess.py ${currDir}/${index}.${i}.bl;done
#Output = fa files

#############################################
#rRNA labelling
#############################################
#input = directory with bl files
#script = rrnaLabel_mouse.py,
            #annotationImporter.py, ncRNAoverlapKeys_mouse.py, utilityModule.py,
            #masterFile.py
#for i in $(seq 18 1 36); do echo python /home/indrikw/script/rna_labelling/rrnaLabel_mouse.py $currDir/ ${i} rRNA; done
#for i in $(seq 18 1 36); do python /home/indrikw/script/rna_labelling/rrnaLabel_mouse.py $currDir/ ${i} rRNA; done
#output = .rll files with rrna labelling

#############################################
#tRNA labelling
#############################################
#input = directory with .rll files
###rename rll to oll for tRNA labelling
#for i in $(seq 18 1 36); do echo mv ${index}.${i}.rll ${index}.${i}.oll; done
#for i in $(seq 18 1 36); do mv ${index}.${i}.rll ${index}.${i}.oll; done
#output = converting .rll files to .oll files

####tRNA labelling
#script = otherRNALabel_mouse.pyc
#for i in $(seq 18 1 36); do echo python /home/indrikw/script/rna_labelling/otherRNALabel_mouse.py $currDir/ ${i} tRNA; done
#for i in $(seq 18 1 36); do python /home/indrikw/script/rna_labelling/otherRNALabel_mouse.py $currDir/ ${i} tRNA; done
#output = oll files tRNA labelling

#####move unlabelled bl files
#echo mkdir unlabelled
#mkdir unlabelled
#echo mv *.bl unlabelled
#mv *.bl unlabelled

#####rename back .oll to .bl
#for i in $(seq 18 1 36); do echo mv ${index}.${i}.oll ${index}.${i}.bl; done
#for i in $(seq 18 1 36); do mv ${index}.${i}.oll ${index}.${i}.bl; done

#output = bl files labelled with contaminants

#############################################
#Generate TXCDUTR
#############################################
#input = directory with bl files
#script = writeTXCDUTRreadsOutput_mouse_vv1.py

#echo python /home/indrikw/script/rpkm/writeTXCDUTRreadsOutput_mouse_vv1_noRefseq.py $rootDir 18,37 RPF
#python /home/indrikw/script/rpkm/writeTXCDUTRreadsOutput_mouse_vv1_noRefseq.py $rootDir 18,37 RPF
#output = gene_TXCDUTR_ReadOutput_date_sample.txt

#############################################
#Generate RPKM
#s############################################
#input = gene_TXCDUTRreadsOutput_date_sample.txt
#script = writeTXCDrpkm_course_vv1.py
#echo python /home/indrikw/script/rpkm/writeTXCDrpkm_course_vv1.py $currDir/gene_TXCDUTR_ReadOutput_${index}.txt
#python /home/indrikw/script/rpkm/writeTXCDrpkm_course_vv1.py $currDir/gene_TXCDUTR_ReadOutput_${index}.txt
#output = gene_TXCDRpkm_ReadOutput_date_sample


#############################################
#Move heavy files (RNASeq)
#############################################
#echo mv ${home_genome_dir}/adapTrim_${i}_sequence.txt /mnt/data/indrik/rnaseq_rep/lane_${lane}
#echo ln -s /mnt/data/indrik/rnaseq_rep/lane_${lane}/adapTrim_${i}_sequence.txt ${home_genome_dir}/adapTrim_${i}_sequence.txt

#echo mv ${home_genome_dir}/triage_${i}_sequence.txt /mnt/data/indrik/rnaseq_rep/lane_${lane}
#echo ln -s /mnt/data/indrik/rnaseq_rep/lane_${lane}/triage_${i}_sequence.txt ${home_genome_dir}/triage_${i}_sequence.txt

#echo mv ${home_genome_dir}/${i}-s_${lane}_1_genome_zeroUn.txt /mnt/data/indrik/rnaseq_rep/lane_${lane}
#echo ln -s /mnt/data/indrik/rnaseq_rep/lane_${lane}/${i}-s_${lane}_1_genome_zeroUn.txt ${home_genome_dir}/${i}-s_${lane}_1_genome_zeroUn.txt

##echo mv ${home_genome_dir}/${i}-s_${lane}_1_genome_twoUn.txt /mnt/data/indrik/rnaseq_rep/lane_${lane}
#echo ln -s /mnt/data/indrikw/rnaseq_rep/lane_${lane}/${i}-s_${lane}_1_genome_twoUn.txt ${home_genome_dir}/${i}-s_${lane}_1_genome_twoUn.txt

#############################################
#Move heavy files (RPF)
#############################################
#mv /home/indrikw/rpf_data/lane_${lane}/${day}-s_${lane}_1/${day}-s_${lane}_1_genome/adapTrim_${day}_sequence.txt /mnt/data/indrik/rpf_data_test/lane_${lane}/
#ln -s /mnt/data/indrik/rpf_data_test/lane_${lane}/adapTrim_${day}_sequence.txt /home/indrikw/rpf_data/lane_${lane}/${day}-s_${lane}_1/${day}-s_${lane}_1_genome/adapTrim_${day}_sequence.txt

#mv /home/indrikw/rpf_data/lane_${lane}/${day}-s_${lane}_1/${day}-s_${lane}_1_genome/triage_${day}_sequence.txt /mnt/data/indrik/rpf_data_test/lane_${lane}
#ln -s /mnt/data/indrik/rpf_data_test/lane_${lane}/triage_${day}_sequence.txt /home/indrikw/rpf_data/lane_${lane}/${day}-s_${lane}_1/${day}-s_${lane}_1_genome/triage_${day}_sequence.txt

#mv /home/indrikw/rpf_data/lane_${lane}/${day}-s_${lane}_1/${day}-s_${lane}_1_genome/${day}-s_${lane}_1_$1_zeroUn.txt /mnt/data/indrik/rpf_data_test/lane_${lane}
#ln -s /mnt/data/indrik/rpf_data_test/lane_${lane}/${day}-s_${lane}_1_$1_zeroUn.txt /home/indrikw/rpf_data/lane_${lane}/${day}-s_${lane}_1/${day}-s_${lane}_1_genome/${day}-s_${lane}_1_$1_zeroUn.txt

#mv /home/indrikw/rpf_data/lane_${lane}/${day}-s_${lane}_1/${day}-s_${lane}_1_genome/${day}-s_${lane}_1_$1_twoUn.txt /mnt/data/indrik/rpf_data_test/lane_${lane}
#ln -s /mnt/data/indrik/rpf_data_test/lane_${lane}/${day}-s_${lane}_1_$1_twoUn.txt /home/indrikw/rpf_data/lane_${lane}/${day}-s_${lane}_1/${day}-s_${lane}_1_genome/${day}-s_${lane}_1_$1_twoUn.txt


