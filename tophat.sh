#!/bin/bash

#specify paths to your working directory and your reads directory
wok_dir='/home/dkiambi/New_diff_exx'
read_dir='/home/dkiambi/New_diff_exx/trim/trimming_output'
cd $wok_dir
#create an overall output directory
mkdir -p tophat
out_dir=$wok_dir/tophat

#make separate output directories within the overall output directories; -p indicates to create the whole path
mkdir -p $out_dir/run_logs
mkdir -p $out_dir/tophat_scripts

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
#SBATCH -o $out_dir/run_logs/map.%N.%j.out
#SBATCH -e $out_dir/run_logs/map.%N.%j.err
#SBATCH --mail-type=END,FAIL

#automatically loads hisat2 and samtools
module load bowtie2 tophat2 samtools
#create bam 
tophat -p 4 -o $out_dir ./HISAT2_ref/Mesculenta_Chr12.fasta $read_dir/$R1 $read_dir/$R2
samtools index $out_dir/$R1_map
samtools flagstat $out_dir/$R1_map > $out_dir/$R1_map'.stats' " > $out_dir/tophat_scripts/$READ'_tophat_slurm.sh'

sbatch $out_dir/tophat_scripts/$READ'_tophat_slurm.sh'
done
