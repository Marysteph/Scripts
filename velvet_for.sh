#!/bin/bash

#specify paths to your working directory and your reads directory
WORK_DIR='/home/dkiambi/ayb_results/'

cd $WORK_DIR

# define paths
READ_DIR1='/var/scratch/AYB_trimmed_data/run1/'
READ_DIR2='/var/scratch/AYB_trimmed_data/run2/'
READ_DIR3='/var/scratch/AYB_trimmed_data/AYB_run3_trimmed_data/'
READ1='1_S1_L001_R1_paired.fastq.gz'
READ2='1_S1_L001_R2_paired.fastq.gz'

for file in 95 105 107 109 111
	do
	
echo \
"#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 4
#SBATCH -w compute03
#SBATCH -o velvet_logs/vh_feb.%N.%j.out
#SBATCH -e velvet_logs/vh_feb.%N.%j.err

# load relevant module
module load velvet/1.2.10-kmer111
#module load jellyfish

# run the the asmebly with the relavant runs, optimising for kmers from 41 to 61 with changes of 5

velveth 'velvet_al_feb'${file} ${file} -fastq.gz -separate \
-shortPaired $READ_DIR3/$READ1 $READ_DIR3/$READ2 \
-shortPaired1 $READ_DIR2/$READ1 $READ_DIR2/$READ2 \
-shortPaired2 $READ_DIR1/$READ1 $READ_DIR1/$READ2 " > velvet_scripts/$file'_velh_slurm.sh'
sbatch velvet_scripts/$file'_velh_slurm.sh'
done

