less ../../Practical4_RicardosExample/References/transformed_coordinates.fasta

grep '>' ../../Practical4_RicardosExample/References/transformed_coordinates.fasta

grep -c '>' ../../Practical4_RicardosExample/References/transformed_coordinates.fasta

gunzip -c ../../Practical4_RicardosExample/reads/Sample_105B/Sample_105B.r1.fastq.gz | wc -l

mkdir -p fastqc trim gtf_splice hisat_index kall_index

module load fastqc

find ../../Practical4_RicardosExample/reads/ -type f -name "*.gz"

fastqc -o fastqc/ -f fastq ./reads/Sample_104B.r1.fastq.gz -t 10

for fi in $(find ../../Practical4_RicardosExample/reads/ -type f -name "*.gz"); do echo processing ${fi};fastqc -t 10 -o fastqc/ -f fastq ${fi};done

