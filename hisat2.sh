#!/bin/bash

#specify paths to your working directory and your reads directory
wok_dir='/home/dkiambi/New_diff_exx'
read_dir='/home/dkiambi/New_diff_exx/trim/trimming_output'
cd $wok_dir
#create an overall output directory
out_dir=$wok_dir/hisat_full_genome

#make separate output directories within the overall output directories; -p indicates to create the whole path
mkdir -p $out_dir/run_logs
mkdir -p $out_dir/HISAT_scripts

#the reads are in pairs in folders, iterate over each pair
for READ in A1 A2 A3 E1 E2 E3
        do
        #specify the input reads and output names
        R1=$READ'_1_trimmed.fastq.gz'
        R2=$READ'_2_trimmed.fastq.gz'
        R1_map=$READ'.bam'

#generate a unique slurm script for this pair
echo \
"#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 4
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH -o ./map.%N.%j.out
#SBATCH -e ./map.%N.%j.err
#SBATCH --mail-type=END,FAIL

#automatically loads hisat2 and samtools
module load hisat2/2.0.5 samtools/1.8
#create bam 
hisat2 -x Cassava_geno/Manihot_esculenta_index -p 10 --dta --known-splicesite-infile Cassava_geno/Manihot_esculenta_splice.txt \
-1 $read_dir/$R1 -2 $read_dir/$R2 | samtools view -bS - -@ 10 > $out_dir/$R1_map " > $out_dir/HISAT_scripts/$READ'_hisat_slurm.sh'

sbatch $out_dir/HISAT_scripts/$READ'_hisat_slurm.sh'
done
