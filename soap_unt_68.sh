#!/bin/bash
#SBATCH -J soap_map_68_un_dave
#SBATCH -p batch
#SBATCH -n 4
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH -o ./soap_map_unt_68.%N.%j.out
#SBATCH -e ./soap_map_unt_68.%N.%j.err
#SBATCH --mail-type=END,FAIL

cd /home/dkiambi/reads

module purge

module load SOAPaligner/2.21

soap -D ./new_map/Zea_mays.AGPv4.dna.toplevel.fa.index -a ./reads/SRR3134468/SRR3134468_1.fastq.gz -b ./reads/SRR3134468/SRR3134468_2.fastq.gz -o ./SRR3134468_unt_soap.txt -2 ./SRR3134468_unt_soap_unpaired.txt -M 4 -p 10

