#!/bin/bash
#SBATCH --cpus-per-task=20
#SBATCH -J my_sam_dave
#SBATCH --mail-user=kika.davies@gmail.com
#SBATCH --mail-type=END,FAIL 
module load bwa

srun ./script_map.sh
