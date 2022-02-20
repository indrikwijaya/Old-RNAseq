file=$1 #ATCACG-s_3_1.sam
prefix=$(echo $file | cut -d'.' -f 1) #ATCACG_s_3_1

#grep -v '^@' ATCACG-s_3_1.sam > ATCACG-s_3_1_noheader.sam
#awk '{print $1,$2,$3,$4,$10,$11}' OFS="\t" ATCACG-s_3_1_noheader.sam > ATCACG-s_3_1_MM.map #collect relevant columns
awk '{print $1,$2,$3,$4,$10,$11}' OFS="\t" ${prefix}"_noheader.sam" > ${prefix}"_MM.map"

#awk '{ if($3 != "*") { print } }' OFS="\t" ATCACG-s_3_1_MM.map > ATCACG-s_3_1_chr_MM.map #remove undetected genes
awk '{ if($3 != "*") { print } }' OFS="\t" ${prefix}"_MM.map" > ${prefix}"_chr_MM.map"

#awk -F"\t" '{$(NF+1)=0;}1' OFS="\t" ATCACG-s_3_1_chr_MM.map > ATCACG-s_3_1_MM.map #add 7th column
awk -F"\t" '{$(NF+1)=0;}1' OFS="\t" ${prefix}"_chr_MM.map" > ${prefix}"_MM.map"

#awk -F"\t" '{$(NF+1)="NA";}1' OFS="\t" ATCACG-s_3_1_MM.map > ATCACG-s_3_1_chr_MM.map #add 8th column
awk -F"\t" '{$(NF+1)="NA";}1' OFS="\t" ${prefix}"_MM.map" > ${prefix}"_chr_MM.map" #add 8th column

#awk -F"\t" '$2=="0" {$2="+"}1' OFS="\t" ATCACG-s_3_1_chr_MM.map > ATCACG-s_3_1_MM.map #convert + strand
awk -F"\t" '$2=="0" {$2="+"}1' OFS="\t" ${prefix}"_chr_MM.map" > ${prefix}"_MM.map" #convert + strand

#awk -F"\t" '$2=="16" {$2="-"}1' OFS="\t" ATCACG-s_3_1_MM.map > ATCACG-s_3_1_chr_MM.map #convert - strand
awk -F"\t" '$2=="16" {$2="-"}1' OFS="\t" ${prefix}"_MM.map" > ${prefix}"_chr_MM.map" #convert - strand

#awk -F"\t" '$4=$4-1' OFS="\t" ATCACG-s_3_1_chr_MM.map > ATCACG-s_3_1_MM.map #change 1-based to 0-based coordinate
awk -F"\t" '$4=$4-1' OFS="\t" ${prefix}"_chr_MM.map" > ${prefix}"_MM.map" #change 1-based to 0-based coordinate

#rm ATCACG-s_3_1_chr_MM.map
rm ${prefix}"_chr_MM.map"

#awk '{ if (($4 <=11000) && ($4>=6400)) { print }}' ATCACG-s_3_1_chrM.sam > ATCACG-s_3_1_chrM_gap.sam