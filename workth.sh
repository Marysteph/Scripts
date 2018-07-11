#!/bin/bash

# load needed modules
module load bwa
module load fastqc
module load trimmomatic
# process files in fastqc
# make new directory
mkdir results
 for file in *.fastq*
do
# give the file being processed
echo "processing ${file}"
# fastqc files with 10 threads and dump output in results folder
fastqc -f fastq -t 10 ${file} -o results
done




