#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 4
#SBATCH -w compute03
#SBATCH -o ./jfm.%N.%j.out
#SBATCH -e ./jfm.%N.%j.err
#SBATCH -p highmem
#SBATCH -n 4     
#SBATCH -w mammoth
# define paths
READ_DIR1='/export/data/ilri/miseq/MiSeq2/MiSeq2Output2018/181128_M03021_0009_000000000-C3F6V_AYB_run1/'
READ_DIR2='/export/data/ilri/miseq/MiSeq2/MiSeq2Output2018/181203_M03021_0010_000000000-C63KC_AYB_run2/'
READ_DIR3='/var/scratch/African_Yam_Bean_TSS11-RUN3-106656809/FASTQ_Generation_2018-12-16_08_18_54Z-143723645/1_L001-ds.1fa37ed4a86a45f6b7f61c434c62fe41/'
READ1='1_S1_L001_R1_001.fastq.gz'
READ2='1_S1_L001_R2_001.fastq.gz'

# load relevant module
module load velvet
#module load jellyfish
# land at appropriate place
cd /home/dkiambi/ayb_results/

# run the the asmebly with the relavant runs, optimising for kmers from 41 to 61 with changes of 5

velveth velvet_out 63 -shortPaired -fastq.gz -separate $READ_DIR2/$READ1 $READ_DIR2/$READ2
