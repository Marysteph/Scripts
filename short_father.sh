#!/bin/bash -e
#BATCH -p batch
#SBATCH -n 10
#SBATCH -o ./_$READ.%N.%j.out
#SBATCH -e ./$OUTPUT_DIR/run_logs/trimmomatic_$READ.%N.%j.err
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH --mail-type=END


#automatically loads 0.38
module load trimmomatic

