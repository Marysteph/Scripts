#!/bin/bash -e
#SBATCH -p highmem
#SBATCH -n 4     
#SBATCH -w mammoth
#SBATCH -o $OUTPUT_DIR/fastq.%N.%j.out 
#SBATCH -e $OUTPUT_DIR/fastq.%N.%j.err
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH --mail-type=END,FAIL