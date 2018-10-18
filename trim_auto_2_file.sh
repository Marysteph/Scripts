#!/bin/bash


#specify paths to your working directory and your reads directory
wok_dir='/home/dkiambi/Module4/'
read_dir=$wok_dir/reads
cd $wok_dir
#create an overall output directory
out_dir=$wok_dir/trim

#make separate output directories within the overall output directories; -p indicates to create the whole path
mkdir -p $out_dir/run_logs
mkdir -p $out_dir/slurm_scripts
mkdir -p $out_dir/trimming_output

reads=($(ls $read_dir))

#the reads are in pairs in folders, iterate over each pair
for READ in ${reads[@]}
        do
        READS_PATH=$read_dir/$READ
        #specify the input reads and output names
        R1=$READ'.r1.fastq.gz'
        R2=$READ'.r2.fastq.gz'
        R1_trimmed=$READ'.trimmed.fastq.gz'
                

#generate a unique slurm script for this pair
echo \
"#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 4
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH -o ./trim.%N.%j.out
#SBATCH -e ./trim.%N.%j.err
#SBATCH --mail-type=END,FAIL

#automatically loads 0.38
module load trimmomatic

#PE for paired end
trimmomatic PE -threads 4 $READS_PATH/$R1 $READS_PATH/$R2 -baseout $out_dir/trimming_output/$R1_trimmed \
LEADING:3 TRAILING:3 SLIDINGWINDOW:4:2 MINLEN:60 AVGQUAL:20 \
" > $out_dir/slurm_scripts/$READ'_trimmomatic_slurm.sh'

sbatch $out_dir/slurm_scripts/$READ'_trimmomatic_slurm.sh'
done
