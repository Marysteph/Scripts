#!/bin/bash
#SBATCH -J soap_map_41_un_dave
#SBATCH -p batch
#SBATCH -n 4
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH -o ./soap_map_utr_41.%N.%j.out
#SBATCH -e ./soap_map_untr_41.%N.%j.err
#SBATCH --mail-type=END,FAIL

cd /home/dkiambi/reads

module purge

module load SOAPaligner/2.21

soap -D ./new_map/Zea_mays.AGPv4.dna.toplevel.fa.index -a ./reads/SRR3134441/SRR3134441_1.fastq.gz -b ./reads/SRR3134441/SRR3134441_2.fastq.gz -o ./SRR3134441_unt_soap.txt -2 ./SRR3134441_unt_soap_unpaired.txt -M 4 -p 10

~

