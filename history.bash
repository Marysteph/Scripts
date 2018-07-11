samtools tview SRR3134441_tr.bam ../Map/Zea_mays.AGPv4.dna.toplevel.fa
for f in *; do echo "Processing ${f}"; module load samtools; samtools index ${f};done
#### vim script for creating a soap index
#!/bin/bash
#SBATCH -J soap_indexing
#SBATCH -p batch
#SBATCH -n 4
#SBATCH --mail-user=DKaimenyi@cgiar.org
#SBATCH -o ./soap_index.%N.%j.out
#SBATCH -e ./soap_index.%N.%j.err
#SBATCH --mail-type=END,FAIL

cd /home/dkiambi/reads/new_map

module load SOAPaligner/2.21

2bwt-builder ./Zea_mays.AGPv4.dna.toplevel.fa -p 10

###multiple jobs
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

for f in *.sh; do echo "submitting ${f}"; sbatch ${f};done

# viewing allingment
cd /var/scratch/Dave/Exercise/reads/
module load tablet
tablet
## blast workthrough
module load blast
makeblastdb -in Exercise/reads/Map/Zea_mays.AGPv4.dna.toplevel.fa -dbtype nucl
blastn -query GW2_rice.fa -db Exercise/reads/Map/Zea_mays.AGPv4.dna.toplevel.fa -out maize_blast.txt -evalue 0.00001 -outfmt 7

blastx -query GW2_rice.fa -db nr -out gw2_blastx.txt -num_threads 10 -max_target_seqs 20 -best_hit_score_edge 0.25

## Generating fasta statistics for downloaded genomes 
for f in ./*; do echo "processing ${f}"; module load seqkit/0.7.2; seqkit stats ${f}; done

