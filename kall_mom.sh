#!/bin/bash

#specify paths to your working directory and your reads directory
wok_dir='/home/dkiambi/trimmed'
read_dir=$wok_dir/trim_read/
cd $wok_dir
#create an overall output directory
out_dir=$wok_dir/kallisto_map

#make separate output directories within the overall output directories; -p indicates to create the whole path
mkdir -p $out_dir/run_logs
mkdir -p $out_dir/slurm_scripts
mkdir -p $out_dir/kall_map_output

reads=($(ls $read_dir))

#the reads are in pairs in folders, iterate over each pair
for READ in ${reads[@]}
        do
        READS_PATH=$read_dir/$READ
        #specify the input reads and output names
        R1=$READ'.trimmed_1P.fastq.gz'
        R2=$READ'.trimmed_2P.fastq.gz'
        R1_map='kall_'$READ


#generate a unique slurm script for this pair
echo \
"#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 4
#SBATCH -w mammoth
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH -o $out_dir/$R1_map'.out'
#SBATCH -e $out_dir/run_logs/map.%N.%j.err
#SBATCH --mail-type=END,FAIL

#automatically loads kallisto
module load kallisto/0.43.0
#create sam 
kallisto quant --pseudobam -i ./kall_index/kall_selected_refseq1 -t 1 -b 1 -o $out_dir/$R1_map $READS_PATH/$R1 $READS_PATH/$R2 
" > $out_dir/slurm_scripts/$READ'_kall_slurm.sh'

sbatch $out_dir/slurm_scripts/$READ'_kall_slurm.sh'
done

echo done
