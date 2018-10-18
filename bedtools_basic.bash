samtools faidx trinity/trinity_group2.fa
# generate a index of the fasta file
cut -f 1-2 trinity/trinity_group2.fa.fai > length.txt
# extract the first 2 fields into a text file
sort -k 2n length.txt
# sort the txt file based on the second column
sort -k 2n length.txt | wc -l 
# get the number of lines in the file
# the 'number+1'/2 if odd
sort -k 2n length.txt | sed '3450q;d' # print the middle line 
sort -k 2n length.txt | head -n 3450 | tail -n 1 # same thing

####gmap exercise

/home/rgonzalez/gmap/bin/gmap_build -d transformed_coordinates -D gmap  transformed_coordinates.fasta #this works but avoid threading

/home/rgonzalez/gmap/bin/gmap --min-intronlength=20 --format=gff3_gene --npaths=1 --ordered --min-identity=0.95 -d \
transformed_coordinates -t 10 -D gmap ../trinity/trinity_group3_2.fa > trinity_group3.gff

/home/rgonzalez/gt/bin/gt gff3 -tidy yes -retainids yes -sort yes trinity_group3.gff > trinity_group3.sorted.gff

for file in *.gff ; do echo "processing ${file:0:-4}"; /home/rgonzalez/gt/bin/gt gff3 -tidy yes -retainids yes -sort yes ${file} > ${file:0:-4}'.sorted.gff'; done

/home/rgonzalez/gt/bin/gt sketch -format pdf -seqid chr1B -start 320232 -end 345985 output1.pdf trinity_group3.sorted.gff

1002 638723
/home/rgonzalez/gt/bin/gt sketch -format pdf -seqid chr5A -start 1002 -end 638723 output1.pdf trinity_group3.sorted.gff
/home/rgonzalez/gt/bin/gt sketch -format pdf -seqid chr5A -start 100000 -end 120000 ~/output2.pdf trinity_group3.sorted.gff
##
#
module load bedtools/2.25.0
# awk -v OFS='\t' -v FS='\t' '$3 == "CDS" {print $1, $4-1, $5, $1 ":" $4 "-" $5 ":" $9}' ../gmap/trinity_group2.sorted.gff | 
# bedtools getfasta -name -fi ../gmap/transformed_coordinates.fasta -bed cds_to_get.gff -fo CDS.fa
awk -v OFS='\t' -v FS='\t' '$3 == "gene" {print $1, $4-1, $5, $1 ":" $4 "-" $5 ":" $9}' ../../gmap/trinity_group2.sorted.gff | bedtools getfasta -name -fi ../../gmap/transformed_coordinates.fasta -bed - -fo ../CDS2.fa
sed -e 's/\(^>.*$\)/#\1;/' CDS1.fa | tr -d "\r" | tr -d "\n" | sed -e 's/$/#/' | tr "#" "\n" > CDS_we_like.fa
for file in $(grep ">" ../gmap/transformed_coordinates.fasta); do echo "processing ${file}"; grep ${file:1:4} CDS_we_like.fa >> ${file:1:5}'.fa';done
##
sed -e 's/\(^>.*$\)/#\1;/' multiseq.fa | tr -d "\r\n" | sed -e 's/$/#/' | tr " " "+" | tr "#" "\n" > new_multiseqfile.fa

for f in $(grep ">" new_multiseqfile.fa | cut -d ";" -f 1-2); do echo "processing ${f}";grep ">" new_m
ultiseqfile.fa > ${f:1}'.fa';done
## 
TransDecoder.LongOrfs -t CDS1.fa