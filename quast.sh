#!/bin/bash

#specify paths to your working directory and your reads directory
WORK_DIR='/home/dkiambi/ayb_results/'

cd $WORK_DIR
mkdir -p quast_scripts quast_logs
for file in $(ls -I "*scripts" -I "*logs" -I "old*" -I "fast*" -I "jellyfish_out" -I "*\.*")
        do

echo \
"#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 2
#SBATCH -o quast_logs/quast.%N.%j.out
#SBATCH -e quast_logs/quast.%N.%j.err

# load approporate module

 module load quast

quast.py ./${file}/contigs.fa -o ./${file}/ -t 2 " > quast_scripts/$file'_slurm.sh'
sbatch quast_scripts/$file'_slurm.sh'
done
