#!/bin/bash

#specify paths to your working directory and your reads directory
WORKING_DIR='/home/dkiambi/Qiime2_limidb/raw_reads/'

cd $WORKING_DIR

#the reads are in pairs in folders, iterate over each pair
for file in $(ls -I "*.sh" -I "*.txt" )
	do
	
	OUTPUT_DIR=${file}/fastq_out
#generate a unique slurm script for ec folder	
echo \
"#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 4
#SBATCH -o $OUTPUT_DIR/fastq.%N.%j.out
#SBATCH -e $OUTPUT_DIR/fastq.%N.%j.err
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH --mail-type=END,FAIL

# automatically load module abyss

module load fastqc

fastqc -o $OUTPUT_DIR -t 10 $file/*.gz " > $OUTPUT_DIR/$file'_fastqc_slurm.sh'

sbatch $OUTPUT_DIR/$file'_fastqc_slurm.sh'
done


####
#!/bin/bash

#specify paths to your working directory and your reads directory
WORKING_DIR='/home/dkiambi/Qiime2_limidb/raw_reads/'

cd $WORKING_DIR

#the reads are in pairs in folders, iterate over each pair
for file in $(ls -I "*.sh" -I "*.txt" )
	do
	
	OUTPUT_DIR=${file}/fastq_out
#generate a unique slurm script for ec folder	
echo \
"#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 4
#SBATCH -o $OUTPUT_DIR/fastq.%N.%j.out
#SBATCH -e $OUTPUT_DIR/fastq.%N.%j.err
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH --mail-type=END,FAIL

# automatically load module abyss

module load multiqc
cd $OUTPUT_DIR

multiqc . " > $OUTPUT_DIR/$file'_fastqc_slurm.sh'

sbatch $OUTPUT_DIR/$file'_fastqc_slurm.sh'
done
