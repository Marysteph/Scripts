#!/bin/bash

#specify paths to your working directory and your reads directory
WORKING_DIR='/home/dkiambi/ayb_results/jellyfish_out'

cd $WORKING_DIR

mkdir -p jf_scripts jf_logs

#the reads are in pairs in folders, iterate over each pair
for file in $(seq 15 6 59)
do
	
echo \
"#!/bin/bash -e
#SBATCH -p batch 
#SBATCH -n 2 
#SBATCH -o ./jf_logs/jfm.%N.%j.out
#SBATCH -e ./jf_logs/jfm.%N.%j.err

module load jellyfish

jellyfish count -t 2 -C -s 5G -m ${file} -o ${file}'mer_out' --min-qual-char=? <(zcat /home/bcop2018/project/AYB/run*/*fastq.gz) 

jellyfish histo -t 2 -o ${file}'mer_out''.histo' ${file}'mer_out' 
" > jf_scripts/$file'_jf_slurm.sh'
sbatch jf_scripts/$file'_jf_slurm.sh'
done
