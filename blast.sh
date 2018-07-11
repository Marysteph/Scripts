#!/bin/bash
#SBATCH -J blastx_dave
#SBATCH -p batch
#SBATCH -n 4
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH -o ./blastx.%N.%j.out
#SBATCH -e ./blastx.%N.%j.err
#SBATCH --mail-type=END,FAIL

cd /home/dkiambi/reads

module purge

module load blast

blastx -query GW2_rice.fa -db nr -out gw2_blastx.txt -num_threads 10 -max_target_seqs 20 -best_hit_score_edge 0.25


