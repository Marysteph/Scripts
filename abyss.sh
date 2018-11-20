#!/bin/bash

#specify paths to your working directory and your reads directory
WORKING_DIR='/home/dkiambi/abyss_assembly'
READ_DIR=$WORKING_DIR/raw_reads
OUTPUT_DIR=$WORKING_DIR/assembly

cd $WORKING_DIR

#make separate output directories within the overall output directories; -p indicates to create the whole path
mkdir -p $OUTPUT_DIR/run_logs
mkdir -p $OUTPUT_DIR/slurm_scripts

#the reads are in pairs in folders, iterate over each pair
for size in 31 41 51 61 71
	do
	
#generate a unique slurm script for this pair	
echo \
"#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 4
#SBATCH -o $OUTPUT_DIR/run_logs/abyss_$size.%N.%j.out
#SBATCH -e $OUTPUT_DIR/run_logs/abyss_$size.%N.%j.err
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH --mail-type=END,FAIL

# automatically load module abyss
module load abyss

abyss-pe j=4 np=4 name='${OUTPUT_DIR}dataset_1_abyss_k_$size' k=${size} in='$READ_DIR/ERR490638_1.fastq.gz $READ_DIR/ERR490638_2.fastq.gz' " > $OUTPUT_DIR/slurm_scripts/$size'_abyss_slurm.sh'

sbatch $OUTPUT_DIR/slurm_scripts/$size'_abyss_slurm.sh'
done
abyss-pe name='cowpea_abyss_61' k=61 in='/home/smaranga/cowpea_data/SRR37167*_1.fastq.gz \/home/smaranga/cowpea_data/SRR37167*_1.fastq.gz' ulimit -v 512000000