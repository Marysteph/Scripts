for file in $(find ../../Practical4_RicardosExample/reads/ -type f -name "*.gz"); do echo "processing ${file}";done
grep -c ">" References/transformed_coordinates.fasta
gunzip -c reads/104B/Sample_104B.r1.fastq.gz | wc -l

mkdir -p fastqc
mkdir -p trim
mkdir -p gtf_splice
mkdir -p hisat_index
mkdir -p kall_index

fastqc/0.11.5
fastqc -o fastqc/ -f fastq reads/Sample_104B.r1.fastq.gz
for file in $(find ../../Practical4_RicardosExample/reads/ -type f -name "*.gz"); do echo "processing ${file}";fastqc \
-o fastqc/ -f fastq ${file} -t 10;done
###### loop for trimming multiple files in different folders

#!/bin/bash

#specify paths to your working directory and your reads directory
wok_dir='/home/dkiambi/Module4/'
read_dir=$wok_dir/reads
cd $wok_dir
#create an overall output directory
out_dir=$wok_dir/trim

#make separate output directories within the overall output directories; -p indicates to create the whole path
mkdir -p $out_dir/run_logs
mkdir -p $out_dir/slurm_scripts
mkdir -p $out_dir/trimming_output

reads=($(ls $read_dir))

#the reads are in pairs in folders, iterate over each pair
for READ in ${reads[@]}
        do
        READS_PATH=$read_dir/$READ
        #specify the input reads and output names
        R1=$READ'.r1.fastq.gz'
        R2=$READ'.r2.fastq.gz'
        R1_trimmed=$READ'.trimmed.fastq.gz'


#generate a unique slurm script for this pair
echo \
"#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 4
#SBATCH -w mammoth
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH -o ./trim.%N.%j.out
#SBATCH -e ./trim.%N.%j.err
#SBATCH --mail-type=END,FAIL

#automatically loads 0.38
module load trimmomatic
#PE for paired end
trimmomatic PE -threads 4 $READS_PATH/$R1 $READS_PATH/$R2 -baseout $out_dir/trimming_output/$R1_trimmed \
LEADING:3 TRAILING:3 SLIDINGWINDOW:4:2 MINLEN:60 AVGQUAL:20 \
" > $out_dir/slurm_scripts/$READ'_trimmomatic_slurm.sh'

sbatch $out_dir/slurm_scripts/$READ'_trimmomatic_slurm.sh'
done

## hisat
module load hisat2/2.0.5
hisat2-build -p 10 ../../Practical4_RicardosExample/References/transformed_coordinates.fasta ./hisat_index/transformed_coordinates_fasta_indx
##cufflinks
module load cufflinks/2.2.1
gffread ../../Practical4_RicardosExample/References/transformed_coordinates.gff -T -o ./gtf_splice/transformed_coordinates.gtf
##python
module load python/3.6.2
## these cmd give similar results
extract_splice_sites.py ./gtf_splice/transformed_coordinates.gtf > ./gtf_splice/transformed_coordinates_splices.txt
hisat2_extract_splice_sites.py ./gtf_splice/transformed_coordinates.gtf > ./gtf_splice/transformed_coordinates_splices2.txt

## kallisto 
module load kallisto/0.43.0

kallisto index -i /kall_index/kall_selected_refseq1 /References/selected_refseq1.0.fasta

for f in trim/*P*.gz; do echo "processing ${f}";module load fastqc; fastqc -o trim_fastqc/ -f fastq ${f} -t 10;done
