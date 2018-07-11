#!/bin/bash

#specify paths to your working directory and your reads directory
wok_dir='/home/dkiambi/New_diff_exx'
read_dir='/home/dkiambi/New_diff_exx/trim/trimming_output'
cd $wok_dir
#create an overall output directory
out_dir=$wok_dir/star_out

#make separate output directories within the overall output directories; -p indicates to create the whole path
mkdir -p $out_dir/run_logs
mkdir -p $out_dir/star_scripts

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
#SBATCH -o ./run_logs/star.%N.%j.out
#SBATCH -e ./run_logs/star.%N.%j.err
#SBATCH --mail-type=END,FAIL

#automatically loads hisat2 and samtools
module load module load star samtools
#create bam 
STAR --runThreadN 8 --runMode alignReads --genomeDir ./HISAT2_ref/ --readFilesCommand zcat --readFilesIn $read_dir/$R1 $read_dir/$R2 --outSAMtype BAM SortedByCoordinate --outSAMattrRGline ID:${READ} SM:${READ} --outFileNamePrefix ${READ} " > $out_dir/star_scripts/$READ'_star_slurm.sh'

sbatch $out_dir/star_scripts/$READ'_star_slurm.sh'
done
