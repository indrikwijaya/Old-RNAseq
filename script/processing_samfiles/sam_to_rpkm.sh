#!/bin/bash

day=$1
lane=$2

label="$day-s_${lane}_1"

#########################
#Convert SAM to MAP
#########################

#samtools view -h ${label}".bam">${label}>".sam"
fileDir="/mnt/data/indrik/bowtie2_test/"

file=${fileDir}${label}".sam" #ATCACG-s_3_1.sam
echo ${file}
inputDir=$3
#prefix=$(echo $file | cut -d'.' -f 1) #ATCACG_s_3_1
#echo $prefix

grep -v '^@' ${file} > ${inputDir}/${label}"_noheader.sam" #remove unwanted SAM headers
echo wc -l ${label}"_noheader.sam"

awk '{print $1,$2,$3,$4,$10,$11}' OFS="\t" ${inputDir}/${label}"_noheader.sam" > ${inputDir}/${label}"_genome_MM.map"
echo wc -l ${label}"_genome_MM.map"
rm ${prefix}"_noheader.sam"

awk '{ if($3 != "*") { print } }' OFS="\t" ${inputDir}/${label}"_genome_MM.map" > ${inputDir}/${label}"_chr_MM.map" #remove undetected genes
echo wc -l ${label}"_chr_MM.map"

awk -F"\t" '{$(NF+1)=0;}1' OFS="\t" ${inputDir}/${label}"_chr_MM.map" > ${inputDir}/${label}"_genome_MM.map" #add 7th column
echo wc -l ${label}"_genome_MM.map"

awk -F"\t" '{$(NF+1)="NA";}1' OFS="\t" ${inputDir}/${label}"_genome_MM.map" > ${inputDir}/${label}"_chr_MM.map" #add 8th column
echo wc -l ${label}"_chr_MM.map"

awk -F"\t" '$2=="0" {$2="+"}1' OFS="\t" ${inputDir}/${label}"_chr_MM.map" > ${inputDir}/${label}"_genome_MM.map" #convert + strand
echo wc -l ${label}"_genome_MM.map"

awk -F"\t" '$2=="16" {$2="-"}1' OFS="\t" ${inputDir}/${label}"_genome_MM.map" > ${inputDir}/${label}"_chr_MM.map" #convert - strand
echo wc -l ${label}"_chr_MM.map"

awk -F"\t" '$4=$4-1' OFS="\t" ${inputDir}/${label}"_chr_MM.map" > ${inputDir}/${label}"_genome_MM.map" #change 1-based to 0-based coordinate
echo wc -l ${label}"_genome_MM.map"

rm ${label}"_chr_MM.map"

#############################################
#Generate BL files
#############################################
#input = directory that contains _MM.map
#script = alignParse_v8_mouse.py
echo python /home/indrikw/script/processing_bl/alignParse_v8_mouse_indrik.py $inputDir/
python /home/indrikw/script/processing_bl/alignParse_v8_mouse_indrik.py $inputDir/
#output = unlabelled bl files

#############################################
#Move heavy files (RNASeq)
#############################################
#library=$(echo $inputDir | cut -d'/' -f 5)
#echo mv ${inputDir}/${file} /mnt/data/indrik/${library}/
#mv ${inputDir}/${file} /mnt/data/indrik/${library}/${file}

#echo ln -s /mnt/data/indrik/${library}/${file} ${inputDir}/${file}
#ln -s /mnt/data/indrik/${library}/${file} ${inputDir}/${file}

rm ${inputDir}/${label}"_genome_MM.map"
#############################################
#Generate FA files
#############################################
#input = directory with bl files
#script = convertBL_mouse.py

for i in $(seq 18 1 36);do echo python /home/indrikw/script/rnaLabelling/convertBL_mouse_subprocess.py ${inputDir}/${label}_genome.${i}.bl;done
for i in $(seq 18 1 36);do python /home/indrikw/script/rnaLabelling/convertBL_mouse_subprocess.py ${inputDir}/${label}_genome.${i}.bl;done

#Output = fa files

#############################################
#rRNA labelling
#############################################
#input = directory with bl files
#script = rrnaLabel_mouse.py,
            #annotationImporter.py, ncRNAoverlapKeys_mouse.py, utilityModule.py,
            #masterFile.py
for i in $(seq 18 1 36); do echo python /home/indrikw/script/rnaLabelling/rrnaLabel_mouse.py ${inputDir}/ ${i} rRNA; done
for i in $(seq 18 1 36); do python /home/indrikw/script/rnaLabelling/rrnaLabel_mouse.py ${inputDir}/ ${i} rRNA; done
#output = .rll files with rrna labelling

#############################################
#tRNA labelling
#############################################
#input = directory with .rll files
###rename rll to oll for tRNA labelling
for i in $(seq 18 1 36); do echo mv $day-s_${lane}_1_genome.${i}.rll ${label}_genome.${i}.oll; done
for i in $(seq 18 1 36); do mv $day-s_${lane}_1_genome.${i}.rll ${label}_genome.${i}.oll; done
#output = converting .rll files to .oll files

####tRNA labelling
#script = otherRNALabel_mouse.pyc
for i in $(seq 18 1 36); do echo python /home/indrikw/script/rnaLabelling/otherRNALabel_mouse.py ${inputDir}/ ${i} tRNA; done
for i in $(seq 18 1 36); do python /home/indrikw/script/rnaLabelling/otherRNALabel_mouse.py ${inputDir}/ ${i} tRNA; done
#output = oll files tRNA labelling

#####move unlabelled bl files
echo mkdir unlabelled
mkdir unlabelled
echo mv *.bl unlabelled
mv *.bl unlabelled

#####rename back .oll to .bl
for i in $(seq 18 1 36); do echo mv $day-s_${lane}_1_genome.${i}.oll ${label}_genome.${i}.bl; done
for i in $(seq 18 1 36); do mv $day-s_${lane}_1_genome.${i}.oll ${label}_genome.${i}.bl; done

#output = bl files labelled with contaminants