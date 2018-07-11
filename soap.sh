#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 4
#SBATCH -o ./soap_SRR3134441.%N.%j.out
#SBATCH -e ./soap_SRR3134441.%N.%j.err

cd /var/scratch/Dave/Exercise/reads/map_out
#load the alligner
module load SOAPaligner/2.21
# run soap

soap -D ./Map/Zea_mays.AGPv4.dna.toplevel.fa.index -a ./reads/SRR3134441_1.fastq.gz -b ./reads/SRR3134441_2.fastq.gz -o ./SRR3134441_soap.txt -2 ./unmapped.txt -M 4 -r a -p 10

