file=$1
day=$2
currdir=$3
rpkm_dir=$4
lane=$5


genome_dir_sym="/data/indrikw/rnaseq_data/lane_${lane}/$day-s_${lane}_1/$day-s_${lane}_1_genome"
genome_dir="/home/indrikw/rpf_data/lane_${lane}/$day-s_${lane}_1/$day-s_${lane}_1_genome"
bowtie_refseq_index="/home/hguo/Documents/indexes/mm9/refseq/m_musculus_refseq"
label="$day-s_${lane}_1_refseq"
index_dir='/home/hguo/Documents/indexes/mm9/m_musculus_genome'

#############################################
#Refseq Processing
#############################################

#############################################
#Bowtie
#############################################
#input = sample_oneUn.txt
echo bowtie --phred64-quals -n 2 -l 29 -e 200 -k 1 -m 1 -p24 ${index_dir} $genome_dir/$day-s_${lane}_1_genome_oneUn.txt $day-s_${lane}_1_genome_twoMM.map --max $day-s_${lane}_1_genome_twoMax.txt --un $day-s_${lane}_1_genome_twoUn.txt
bowtie --phred64-quals -n 2 -l 29 -e 200 -k 1 -m 1 -p24 ${index_dir} $genome_dir/$day-s_${lane}_1_genome_oneUn.txt $day-s_${lane}_1_genome_twoMM.map --max $day-s_${lane}_1_genome_twoMax.txt --un $day-s_${lane}_1_genome_twoUn.txt
#output = _twoMM.map, _twoMax.txt, _twoUn.txt

#n = 0
#input = _twoUn.txt
echo bowtie --phred64-quals -n 0 -l 29 -e 200 -k 1 -m 1 -p24 $bowtie_refseq_index $day-s_${lane}_1_genome_twoUn.txt ${label}_zeroMM.map --un ${label}_zeroUn.txt
bowtie --phred64-quals -n 0 -l 29 -e 200 -k 1 -m 1 -p24 $bowtie_refseq_index $day-s_${lane}_1_genome_twoUn.txt ${label}_zeroMM.map --un ${label}_zeroUn.txt
#output = _refseq_zeroUn.txt

#n = 1
#input = _refseq_zeroUn.txt
echo bowtie --phred64-quals -n 1 -l 29 -e 200 -k 1 -m 1 -p24 $bowtie_refseq_index ${label}_zeroUn.txt ${label}_oneMM.map --un ${label}_oneUn.txt
bowtie --phred64-quals -n 1 -l 29 -e 200 -k 1 -m 1 -p24 $bowtie_refseq_index ${label}_zeroUn.txt ${label}_oneMM.map --un ${label}_oneUn.txt
#output = _refseq_oneUn.txt

#n= 2
#input = _refseq_oneUn.txt
echo bowtie --phred64-quals -n 2 -l 29 -e 200 -y -k 1 -m 1 -p24 $bowtie_refseq_index ${label}_oneUn.txt ${label}_twoMM.map --un ${label}_twoUn.txt
bowtie --phred64-quals -n 2 -l 29 -e 200 -y -k 1 -m 1 -p24 $bowtie_refseq_index ${label}_oneUn.txt ${label}_twoMM.map --un ${label}_twoUn.txt

#############################################
#Move big files
#############################################
#mv /home/indrikw/rpf_data/lane_${lane}/${day}-s_${lane}_1/${day}-s_${lane}_1_refseq/${day}-s_${lane}_1_refseq_oneUn.txt /mnt/data/indrik/rpf_data_test/lane_${lane}
#ln -s /mnt/data/indrik/rpf_data_test/lane_${lane}/${day}-s_${lane}_1_refseq_oneUn.txt /home/indrikw/rpf_data/lane_${lane}/${day}-s_${lane}_1/${day}-s_${lane}_1_refseq/${day}-s_${lane}_1_refseq_oneUn.txt

#mv /home/indrikw/rpf_data/lane_${lane}/${day}-s_${lane}_1/${day}-s_${lane}_1_refseq/${day}-s_${lane}_1_refseq_twoUn.txt /mnt/data/indrik/rpf_data_test/lane_${lane}
#ln -s /mnt/data/indrik/rpf_data_test/lane_${lane}/${day}-s_${lane}_1_refseq_twoUn.txt /home/indrikw/rpf_data/lane_${lane}/${day}-s_${lane}_1/${day}-s_${lane}_1_refseq/${day}-s_${lane}_1_refseq_twoUn.txt

#mv /home/indrikw/rpf_data/lane_${lane}/${day}-s_${lane}_1/${day}-s_${lane}_1_refseq/${day}-s_${lane}_1_genome_twoMax.txt /mnt/data/indrik/rpf_data_test/lane_${lane}
#ln -s /mnt/data/indrik/rpf_data_test/lane_${lane}/${day}-s_${lane}_1_genome_twoMax.txt /home/indrikw/rpf_data/lane_${lane}/${day}-s_${lane}_1/${day}-s_${lane}_1_refseq/${day}-s_${lane}_1_genome_twoMax.txt

#mv /home/indrikw/rpf_data/lane_${lane}/${day}-s_${lane}_1/${day}-s_${lane}_1_refseq/${day}-s_${lane}_1_genome_twoUn.txt /mnt/data/indrik/rpf_data_test/lane_${lane}
#ln -s /mnt/data/indrik/rpf_data_test/lane_${lane}/${day}-s_${lane}_1_genome_twoUn.txt /home/indrikw/rpf_data/lane_${lane}/${day}-s_${lane}_1/${day}-s_${lane}_1_refseq/${day}-s_${lane}_1_genome_twoUn.tx

#############################################
#faDict process
#############################################
#input = _refseq_zeroMM.map, _refseq_oneMM.map, _refseq_twoMM.map
#script = faDict_v7_mouse.py
echo python /home/indrikw/script/processing_refseq/faDict_v7_mouse.py $currdir/
python /home/indrikw/script/processing_refseq/faDict_v7_mouse.py $currdir/
#output = _refseq.x.bl

#############################################
#blbed2 process
#############################################
#input = _refseq.x.bl
#script = annotateBed_v7_mouse.py
echo python /home/indrikw/processing_refseq/annotateBed_v7_mouse.py $currdir/
python /home/indrikw/processing_refseq/annotateBed_v7_mouse.py $currdir/
#output = _refseq.x.blbed2

#############################################
#convert to fa
#############################################
#input = _refseq.x.bl
#scscript = convertBL_mouse.py
for i in $(seq 18 1 36); do echo python /home/indrikw/script/rnaLabelling/convertBL_mouse.py ${label}.${i}.bl;done
for i in $(seq 18 1 36);do python /home/indrikw/script/rnaLabelling/convertBL_mouse.py ${label}.${i}.bl;done
#output = _refseq.x.fa

#############################################
#rRNA labelling
#############################################
#input = directory with bl files
#script = /home/indrikw/script/rnaLabelling/rrnaLabel_mouse.py,
            #annotationImporter.py, ncRNAoverlapKeys_mouse.py, utilityModule.py,
            #masterFile.py
for x in $(seq 18 1 36); do echo python /home/indrikw/script/rnaLabelling/rrnaLabel_mouse.py $currdir/ ${x} rRNA; done
for x in $(seq 18 1 36); do python /home/indrikw/script/rnaLabelling/rrnaLabel_mouse.py $currdir/ ${x} rRNA; done
#output = .rll files with rrna labelling

#############################################
#tRNA labelling
#############################################
#input = directory with .rll files
for i in $(seq 18 1 36);do echo mv $day-s_${lane}_1_refseq.${i}.rll  ${label}.${i}.oll; done
for i in $(seq 18 1 36);do mv $day-s_${lane}_1_refseq.${i}.rll  ${label}.${i}.oll; done
#output = converting .rll files to .oll files

#script = otherRNALabel_mouse.py
for x in $(seq 18 1 36); do echo python /home/indrikw/script/rnaLabelling/otherRNALabel_mouse.py $currdir/ ${x} tRNA; done
for x in $(seq 18 1 36); do python /home/indrikw/script/rnaLabelling/otherRNALabel_mouse.py $currdir/ ${x} tRNA; done
#output = oll files tRNA labelling

echo mkdir unlabelled
mkdir unlabelled
echo mv *.bl unlabelled
mv *.bl unlabelled
for i in $(seq 18 1 36);do echo mv $day-s_${lane}_1_refseq.${i}.oll  ${label}.${i}.bl; done
for i in $(seq 18 1 36);do mv $day-s_${lane}_1_refseq.${i}.oll  ${label}.${i}.bl; done
#output = bl files labelled with contaminants

#############################################
#Generate TXCDUTR
#############################################
#input = directory with bl files
#script = writeTXCDUTRreadsOutput_mouse_vv1.py
#python /home/indrikw/script/rpkm/writeTXCDUTRreadsOutput_mouse_vv1.py $refseq_blDirectory 18,37 RPF
#output = gene_TXCDUTR_ReadOutput_date_sample.txt

#############################################
#Generate RPKM
#############################################
#input = gene_TXCDUTRreadsOutput_date_sample.txt
#script = writeTXCDrpkm_course_vv1.py
#python /home/indrikw/script/rpkm/writeTXCDrpkm_course_vv1.py $refseq_TXCDUTRdirectory
#output = gene_TXCDRpkm_ReadOutput_date_sample.txt

