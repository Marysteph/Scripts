#!/bin/bash
#SBATCH -J soap_map_67_dave
#SBATCH -p batch
#SBATCH -n 4
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH -o ./soap_map_67.%N.%j.out
#SBATCH -e ./soap_map_67.%N.%j.err
#SBATCH --mail-type=END,FAIL

cd /home/dkiambi/reads

module purge

module load SOAPaligner/2.21

soap -D ./new_map/Zea_mays.AGPv4.dna.toplevel.fa.index -a ./out_2018_06_05_12_38/trimming_output/SRR3134467_1_trimmed.fastq.gz -b ./out_2018_06_05_12_38/trimming_output/SRR3134467_2_trimmed.fastq.gz -o ./SRR3134467_soap_.txt -2 ./SRR3134467_soap_unpaired.txt -M 4 -p 10

