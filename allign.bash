## removing all sam files
for a in $(find ./ -type f -name "*.sam"); do echo "removing ${a}"; rm -f ${a}; done
## creating new folders
mkdir -p alignments alignments/kallisto alignments/HISAT2 stringtie_output
## module loaded
module load hisat2/2.0.5 samtools/1.8

hisat2 -x hisat_index/transformed_coordinates_fasta_indx -p 10 --dta --known-splicesite-infile gtf_splice/transformed_coordinates_splices.txt \
-1 trim/Sample_104B.trimmed_1P.fastq.gz -2 trim/Sample_104B.trimmed_2P.fastq.gz | samtools view -bS - -@ 10 > alignments/HISAT2/104B_P.bam
## creating new directories for all samples
for f in $(ls * |cut -d '.' -f 1);do echo ${f};mkdir -p ${f};done

## making a sbatch script for doing hisat2 map and piping it into a bam for all samples

#!/bin/bash

#specify paths to your working directory and your reads directory
wok_dir='/home/dkiambi/trimmed' 
read_dir=$wok_dir/trim_read/
cd $wok_dir
#create an overall output directory
out_dir=$wok_dir/map

#make separate output directories within the overall output directories; -p indicates to create the whole path
mkdir -p $out_dir/run_logs
mkdir -p $out_dir/slurm_scripts
mkdir -p $out_dir/map_output

reads=($(ls $read_dir))

#the reads are in pairs in folders, iterate over each pair
for READ in ${reads[@]}
        do
        READS_PATH=$read_dir/$READ
        #specify the input reads and output names
        R1=$READ'.trimmed_1P.fastq.gz'
        R2=$READ'.trimmed_2P.fastq.gz'
        R1_map=$READ'.bam'


#generate a unique slurm script for this pair
echo \
"#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 4
#SBATCH -w mammoth
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH -o ./map.%N.%j.out
#SBATCH -e ./map.%N.%j.err
#SBATCH --mail-type=END,FAIL

#automatically loads hisat2 and samtools
module load hisat2/2.0.5 samtools/1.8
#create bam 
hisat2 -x ./hisat_index/transformed_coordinates_fasta_indx -p 10 --dta --known-splicesite-infile ./gtf_splice/transformed_coordinates_splices.txt \
-1 $READS_PATH/$R1 -2 $READS_PATH/$R2 | samtools view -bS - -@ 10 > $out_dir/$R1_map " > $out_dir/slurm_scripts/$READ'_hisat_slurm.sh'

sbatch $out_dir/slurm_scripts/$READ'_hisat_slurm.sh'
done
######
samtools sort -@ 10 alignments/HISAT2/104B_P.bam -o alignments/HISAT2/sorted_104B_P.bam

for c in *.bam; do echo "processing ${c}"; samtools sort -@ 10 ${c} -o 'sorted_'${c};done

module load stringtie/1.3.4d

stringtie alignments/HISAT2/sorted_104B_P.bam -p 8 -G References/transformed_coordinates.gff -l strg -o /stringtie_output/104B_P_string.gtf
for v in sorted_*; do echo "processing ${v}";stringtie ${v} -p 12 -G ../../../../Practical4_RicardosExample/References/transformed_coordinates.gff\
 -l strg -o ../../stringtie_output/${v}'_string.gtf';done
 
stringtie --merge -p 12 -G ../../Practical4_RicardosExample/References/transformed_coordinates.gff -l mrg -o \
stringtie_output/merge_stringtie_gtf gtf_splice/list_gtf.txt 
 

stringtie -e -B -p 8 -G stringtie_output/merge_stringtie_gtf -o ./ballgown_str_mrg/104B/104B_vs_mrg_gtf.gtf alignments/HISAT2/sorted_104B_P.bam

for x in alignments/HISAT2/sorted_* ; do echo "processing ${x}";stringtie -e -B -G stringtie_output/merge_stringtie_gtf -o \
./ballgown_str_mrg/${x:25:-4}/${x:25:-4}'vs_mrg_gtf.gtf' -p 10 ${x};done

### sbatch for kallisto map 
#!/bin/bash

#specify paths to your working directory and your reads directory
wok_dir='/home/dkiambi/trimmed'
read_dir=$wok_dir/trim_read/
cd $wok_dir
#create an overall output directory
out_dir=$wok_dir/kallisto_map

#make separate output directories within the overall output directories; -p indicates to create the whole path
mkdir -p $out_dir/run_logs
mkdir -p $out_dir/slurm_scripts
mkdir -p $out_dir/kall_map_output

reads=($(ls $read_dir))

#the reads are in pairs in folders, iterate over each pair
for READ in ${reads[@]}
        do
        READS_PATH=$read_dir/$READ
        #specify the input reads and output names
        R1=$READ'.trimmed_1P.fastq.gz'
        R2=$READ'.trimmed_2P.fastq.gz'
        R1_map='kall_'$READ


#generate a unique slurm script for this pair
echo \
"#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 4
#SBATCH -w mammoth
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH -o $out_dir/$R1_map'.out'
#SBATCH -e $out_dir/run_logs/map.%N.%j.err
#SBATCH --mail-type=END,FAIL

#automatically loads kallisto
module load kallisto/0.43.0
#create bam 
kallisto quant --pseudobam -i ./kall_index/kall_selected_refseq1 -t 10 -b 10 -o $out_dir/$R1_map $READS_PATH/$R1 $READS_PATH/$R2 
" > $out_dir/slurm_scripts/$READ'_kall_slurm.sh'

sbatch $out_dir/slurm_scripts/$READ'_kall_slurm.sh'
done

echo done
####
module load samtools

samtools sort alignments_kallisto/filename.out -o -@ 10 alignments_kallisto/kall_sorted_104B_P.bam

for o in alignments/kallisto/*.out; do echo "processing ${o}"; module load samtools; samtools sort ${o} \
-@ 10 -o alignments/kallisto/'kall_sorted_'${o:25:4}'.bam';done


