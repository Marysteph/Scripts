#!/bin/bash -e
#SBATCH -p highmem
#SBATCH -n 16     
#SBATCH -w mammoth   
#SBATCH -o ./jf.%N.%j.out 
#SBATCH -e ./jf.%N.%j.err

# define paths 
READ_DIR1='/home/bcop2018/project/AYB/run1/'
READ_DIR2='/home/bcop2018/project/AYB/run2/'
READ1='1_S1_L001_R1_paired.fastq.gz'
READ2='1_S1_L001_R2_paired.fastq.gz'

# load relevant module
module load velvet
module load jellyfish
# land at appropriate place
cd /home/dkiambi/ayb_results/jellyfish_out

# run the the asmebly with the relavant runs, optimising for kmers from 41 to 61 with changes of 5

#velveth velvet_out 41,61,5 -shortPaired -fastq.gz -separate $READ_DIR2/$READ1 $READ_DIR2/$READ2

#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 4
#SBATCH -o ./jfm.%N.%j.out
#SBATCH -e ./jfm.%N.%j.err

# define paths
READ_DIR1='/home/bcop2018/project/AYB/run1/'
READ_DIR2='/home/bcop2018/project/AYB/run2/'
READ1='1_S1_L001_R1_paired.fastq.gz'
READ2='1_S1_L001_R2_paired.fastq.gz'

# load relevant module
#module load velvet
module load jellyfish
# land at appropriate place
cd /home/dkiambi/ayb_results/jellyfish_out

# run the the asmebly with the relavant runs, optimising for kmers from 41 to 61 with changes of 5

velveth velvet_out 41,61,5 -shortPaired -fastq.gz -separate $READ_DIR2/$READ1 $READ_DIR2/$READ2

jellyfish count -t 4 -C -s 5G -m 41 -o 41mer_out --min-qual-char=? <(zcat /home/bcop2018/project/AYB/run*/*fastq.gz)



#velvetg output_directory/ -cov_cutoff auto

#!/bin/bash

#specify paths to your working directory and your reads directory
WORK_DIR='/home/dkiambi/ayb_results/'

cd $WORK_DIR
mkdir -p velvet_scripts velvet_logs
for file in $(ls -I "*.sh" -I "*.txt" -I "*.out" -I "*.err" -I "fast*" -I "jellyfish_out")
	do
	
echo \
"#!/bin/bash -e
#SBATCH -p batch 
#SBATCH -n 4 
#SBATCH -o velvet_logs/velvetg.%N.%j.out 
#SBATCH -e velvet_logs/velvetg.%N.%j.err 
  # load approporate module

 module load velvet
 
velvetg ${file}/ -cov_cutoff auto " > velvet_scripts/$file'_velg_slurm.sh'
sbatch velvet_scripts/$file'_velg_slurm.sh'
done