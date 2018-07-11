#!/bin/bash

#specify paths to your working directory and your reads directory
wok_dir='/home/dkiambi/trimmed'
read_dir=$wok_dir/trim_read/
cd $wok_dir
#create an overall output directory
out_dir=$wok_dir/map

#make separate output directories within the overall output directories; -p indicates to create the whole path
mkdir -p $out_dir/run_logs
mkdir -p $out_dir/slurm_scripts
mkdir -p $out_dir/map_output

reads=($(ls $read_dir))

#the reads are in pairs in folders, iterate over each pair
for READ in ${reads[@]}
        do
        READS_PATH=$read_dir/$READ
        #specify the input reads and output names
        R1=$READ'.trimmed_1P.fastq.gz'
        R2=$READ'.trimmed_2P.fastq.gz'
        R1_map=$READ'.bam'


#generate a unique slurm script for this pair
echo \
"#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 4
#SBATCH -w mammoth
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH -o ./map.%N.%j.out
#SBATCH -e ./map.%N.%j.err
#SBATCH --mail-type=END,FAIL

#automatically loads hisat2 and samtools
module load hisat2/2.0.5 samtools/1.8
#create bam 
hisat2 -x ./hisat_index/transformed_coordinates_fasta_indx -p 10 --dta --known-splicesite-infile ./gtf_splice/transformed_coordinates_splices.txt \
-1 $READS_PATH/$R1 -2 $READS_PATH/$R2 | samtools view -bS - -@ 10 > $out_dir/$R1_map " > $out_dir/slurm_scripts/$READ'_hisat_slurm.sh'

sbatch $out_dir/slurm_scripts/$READ'_hisat_slurm.sh'
done
