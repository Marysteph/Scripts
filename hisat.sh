#!/bin/bash

#specify paths to your working directory and your reads directory
wok_dir='/home/dkiambi/New_diff_exx'
read_dir='/home/dkiambi/New_diff_exx/trim/trimming_output'
cd $wok_dir
#create an overall output directory
out_dir=$wok_dir/HISAT_out

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
#SBATCH -o ./HISAT_out/map.%N.%j.out
#SBATCH -e ./HISAT_out/map.%N.%j.err
#SBATCH --mail-type=END,FAIL

#automatically loads hisat2 and samtools
module load hisat2/2.0.5 samtools/1.8
#create bam 
hisat2 -x ./HISAT2_ref/Mesculenta_Chr12_indx -p 4 --dta --known-splicesite-infile ./HISAT2_ref/Mesculenta_splices2.txt \
-1 $read_dir/$R1 -2 $read_dir/$R2 | samtools view -bS - -@ 4 > $out_dir/$R1_map " > $out_dir/HISAT_scripts/$READ'_hisat_slurm.sh'

sbatch $out_dir/HISAT_scripts/$READ'_hisat_slurm.sh'
done
