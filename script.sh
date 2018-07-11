#!/bin/bash

#specify paths to your working directory and your reads directory
wok_dir='/home/dkiambi/New_diff_exx'
read_dir='/home/agisel/Course/'
cd $wok_dir
#create an overall output directory
out_dir=$wok_dir/trim

#make separate output directories within the overall output directories; -p indicates to create the whole path
mkdir -p $out_dir/run_logs
mkdir -p $out_dir/slurm_scripts
mkdir -p $out_dir/trimming_output


#the reads are in pairs in folders, iterate over each pair
for READ in A1 A2 A3 E1 E2 E3
        do
        #specify the input reads and output names
        R1=$READ'-R1.fastq.gz'
        R2=$READ'-R2.fastq.gz'
        R1_trimmed=$READ'_1_trimmed.fastq.gz'
	R1_unpaired=$READ'_1_unpaired.fastq.gz'
	R2_trimmed=$READ'_2_trimmed.fastq.gz'
	R2_unpaired=$READ'_2_unpaired.fastq.gz'


#generate a unique slurm script for this pair
echo \
"#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 4
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH -o ./trim/trim.%N.%j.out
#SBATCH -e ./trim/trim.%N.%j.err
#SBATCH --mail-type=END,FAIL

#automatically loads 0.38
module load trimmomatic
#PE for paired end
trimmomatic PE -threads 4 $read_dir/$R1 $read_dir/$R2 $out_dir/trimming_output/$R1_trimmed \
$out_dir/trimming_output/$R1_unpaired $out_dir/trimming_output/$R2_trimmed $out_dir/trimming_output/$R2_unpaired \
ILLUMINACLIP:/home/emurungi/TruSeq3-PE-2.fa:2:30:10 HEADCROP:10 TRAILING:3 SLIDINGWINDOW:4:20 AVGQUAL:20 MINLEN:60 \
" > $out_dir/slurm_scripts/$READ'_trimmomatic_slurm.sh'

sbatch $out_dir/slurm_scripts/$READ'_trimmomatic_slurm.sh'
done

