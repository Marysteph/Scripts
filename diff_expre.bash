# trim reads

#!/bin/bash

#specify paths to your working directory and your reads directory
wok_dir='/home/dkiambi/New_diff_exx'    # the working directory with relevant files and folders
read_dir='/home/agisel/Course/' 		# folder with reads
cd $wok_dir
#create an overall output directory
out_dir=$wok_dir/trim					# location of output directory, created before

#make separate output directories within the overall output directories; -p indicates to create the whole path
mkdir -p $out_dir/run_logs
mkdir -p $out_dir/slurm_scripts
mkdir -p $out_dir/trimming_output


#the reads are in pairs in one folder, iterate over each pair
for READ in A1 A2 A3 E1 E2 E3   		#pattern of files 
        do
        #specify the input reads and output names
        R1=$READ'-R1.fastq.gz'   		# expanded to E2-R1.fastq.gz
        R2=$READ'-R2.fastq.gz'
        R1_trimmed=$READ'_1_trimmed.fastq.gz'
		R1_unpaired=$READ'_1_unpaired.fastq.gz'
		R2_trimmed=$READ'_2_trimmed.fastq.gz'
		R2_unpaired=$READ'_2_unpaired.fastq.gz'


#generate a unique slurm script for this pair
echo \
"#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 4
#SBATCH --mail-user=D.Kaimenyi@cgiar.org      
#SBATCH -o ./trim.%N.%j.out
#SBATCH -e ./trim.%N.%j.err
#SBATCH --mail-type=END,FAIL

#automatically loads 0.38
module load trimmomatic
#PE for paired end
trimmomatic PE -threads 4 $read_dir/$R1 $read_dir/$R2 $out_dir/trimming_output/$R1_trimmed \
$out_dir/trimming_output/$R1_unpaired $out_dir/trimming_output/$R2_trimmed $out_dir/trimming_output/$R2_unpaired 
ILLUMINACLIP:/home/emurungi/TruSeq3-PE-2.fa:2:30:10 HEADCROP:10 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:60 AVGQUAL:20 \
" > $out_dir/slurm_scripts/$READ'_trimmomatic_slurm.sh'

sbatch $out_dir/slurm_scripts/$READ'_trimmomatic_slurm.sh'
done
##

# copy the reference files
cp /home/agisel/Course/Mesculenta_* ./HISAT2_ref/
# index the refernce with hisat
hisat2-build -p 10 HISAT2_ref/Mesculenta_Chr12.fasta HISAT2_ref/Mesculenta_Chr12_indx

module load cufflinks/2.2.1

gffread HISAT2_ref/Mesculenta_305_v6.1.gene_exons.gff3 -T -o HISAT2_ref/Mesculenta_305_v6.1.gene_exons.gtf
#extract splice sites
hisat2_extract_splice_sites.py HISAT2_ref/Mesculenta_305_v6.1.gene_exons.gtf > HISAT2_ref/Mesculenta_splices2.txt
# run hisat map

#!/bin/bash

#specify paths to your working directory and your reads directory
wok_dir='/home/dkiambi/New_diff_exx'
read_dir='/home/dkiambi/New_diff_exx/trim/trimming_output'
cd $wok_dir
#create an overall output directory
out_dir=$wok_dir/HISAT_out

#make separate output directories within the overall output directories; -p indicates to create the whole path
mkdir -p $out_dir/run_logs
mkdir -p $out_dir/HISAT_scripts



#the reads are in pairs in folders, iterate over each pair
for READ in A1 A2 A3 E1 E2 E3
        do
        #specify the input reads and output names
        R1=$READ'_1_trimmed.fastq.gz'
        R2=$READ'_2_trimmed.fastq.gz'
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
hisat2 -x HISAT2_ref/Mesculenta_Chr12_indx -p 10 --dta --known-splicesite-infile HISAT2_ref/Mesculenta_splices2.txt \
-1 $read_dir/$R1 -2 $read_dir/$R2 | samtools view -bS - -@ 10 > $out_dir/$R1_map " > $out_dir/HISAT_scripts/$READ'_hisat_slurm.sh'

sbatch $out_dir/HISAT_scripts/$READ'_hisat_slurm.sh'
done
 
# sort with samtools 
for c in *.bam; do echo "processing ${c}"; samtools sort -@ 10 ${c} -o 'sorted_'${c};done

# stringtie
for v in sorted_*; do echo "processing ${v}"; module load stringtie;stringtie ${v} -p 12 -G ../HISAT2_ref/Mesculenta_305_v6.1.gene_exons.gff3 -l strg -o ../Stingtie/${v}'_string.gtf';done

# create list of gtf file created by stringtie
for f in Stingtie/*; do echo ${f} > list_gtf.txt ;done
# merge the files
stringtie --merge -p 12 -G HISAT2_ref/Mesculenta_305_v6.1.gene_exons.gff3 -l mrg -o Stingtie/merge_stringtie_gtf list_gtf.txt 
# re-estimate transcript abundances and create tables of counts for Ballgown
for x in HISAT_out/sorted_* ; do echo "processing ${x}";stringtie -e -B -G Stingtie/merge_stringtie_gtf -o \
ballgown_str_mrg/'1_'${x:17:-4}/'1_'${x:17:-4}'_vs_mrg_gtf.gtf' -p 10 ${x};done
## take care to string_subset based on your filing system #${x:17:-4}# count the cnumber of charaters to statrt position
# clean the substring with  a basic 
for x in HISAT_out/sorted_* ; do echo "processing ${x:17:-4}"; done 
# transfer the cleaned substring to th ecommand only when sure it is whta you want
# working with full genome

wget #relevant fa.gz and assocated gff3 files
gunzip #ref #gff3
# index the ref
module load hisat2
hisat2-build -p 10 Manihot_esculenta.Manihot_esculenta_v6.dna.toplevel.fa Manihot_esculenta_index
# create intermediate gtf file
module load cufflinks/2.2.1
gffread Manihot_esculenta.Manihot_esculenta_v6.39.gff3  -T -o Manihot_esculenta.Manihot_esculenta_v6.39.gtf
#extract splice sites
hisat2_extract_splice_sites.py Manihot_esculenta.Manihot_esculenta_v6.39.gtf > Manihot_esculenta_splice.txt

#!/bin/bash

#specify paths to your working directory and your reads directory
wok_dir='/home/dkiambi/New_diff_exx'
read_dir='/home/dkiambi/New_diff_exx/trim/trimming_output'
cd $wok_dir
#create an overall output directory
out_dir=$wok_dir/hisat_full_genome

#make separate output directories within the overall output directories; -p indicates to create the whole path
mkdir -p $out_dir/run_logs
mkdir -p $out_dir/HISAT_scripts



#the reads are in pairs in folders, iterate over each pair
for READ in A1 A2 A3 E1 E2 E3
        do
        #specify the input reads and output names
        R1=$READ'_1_trimmed.fastq.gz'
        R2=$READ'_2_trimmed.fastq.gz'
        R1_map=$READ'.bam'

#generate a unique slurm script for this pair
echo \
"#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 4
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH -o ./map.%N.%j.out
#SBATCH -e ./map.%N.%j.err
#SBATCH --mail-type=END,FAIL

#automatically loads hisat2 and samtools
module load hisat2/2.0.5 samtools/1.8
#create bam 
hisat2 -x Cassava_geno/Manihot_esculenta_index -p 10 --dta --known-splicesite-infile Cassava_geno/Manihot_esculenta_splice.txt \
-1 $read_dir/$R1 -2 $read_dir/$R2 | samtools view -bS - -@ 10 > $out_dir/$R1_map " > $out_dir/HISAT_scripts/$READ'_hisat_slurm.sh'

sbatch $out_dir/HISAT_scripts/$READ'_hisat_slurm.sh'
done
#
for c in *.bam; do echo "processing ${c}"; samtools sort -@ 10 ${c} -o 'sorted_'${c};done
#
for v in sorted_*; do echo "processing ${v}"; module load stringtie;stringtie ${v} -p 12 -G \
../Cassava_geno/Manihot_esculenta.Manihot_esculenta_v6.39.gff3 -l strg -o ../Stingtie/${v}'_string.gtf';done

# create list of gtf file created by stringtie
for f in STRINGTIE_full_genome/*gtf; do echo ${f} >> list_gtf.txt ;done
# merge the files
stringtie --merge -p 12 -G Cassava_geno/Manihot_esculenta.Manihot_esculenta_v6.39.gff3 -l mrg -o STRINGTIE_full_genome/merge_stringtie_gtf list_gtf_2.txt  
# re-estimate transcript abundances and create tables of counts for Ballgown
for x in hisat_full_genome/sorted_* ; do echo "processing ${x}";stringtie -e -B -G \
STRINGTIE_full_genome/merge_stringtie_gtf -o Ballgown_str_full_genome/'1_'${x:25:-4}/'1_'${x:25:-4}'_vs_mrg_gtf.gtf' -p 10 ${x};done

##
#star 
### thursday arabidopsis
module load star samtools

STAR --runThreadN 10 --runMode  genomeGenerate --genomeDir  ./ --genomeFastaFiles  Mesculenta_Chr12.fasta \
--sjdbGTFfile Mesculenta_305_v6.1.gene_exons.gtf --sjdbOverhang 140

#star alligner
STAR --runThreadN 4 --runMode alignReads --genomeDir ./HISAT2_ref/ --readFilesCommand zcat --readFilesIn {$At_accn}_R1_trimmomatic.fq.gz --outSAMtype BAM SortedByCoordinate --outSAMattrRGline ID:$At_accn SM:$At_accn --outFileNamePrefix ${At_accn}
# loop 
for fil in trim/trimming_output/*trimmed*.gz; do echo "processing ${fil}"; STAR --runThreadN 16 --runMode alignReads --genomeDir ./HISAT2_ref/ --readFilesCommand zcat --readFilesIn ${fil} --outSAMtype BAM SortedByCoordinate --outSAMattrRGline ID:${fil:21:2} SM:${fil:21:2} --outFileNamePrefix ${fil:21:2};done
#####
#!/bin/bash

#specify paths to your working directory and your reads directory
wok_dir='/home/dkiambi/New_diff_exx'
read_dir='/home/dkiambi/New_diff_exx/trim/trimming_output'
cd $wok_dir
#create an overall output directory
out_dir=$wok_dir/star_out

#make separate output directories within the overall output directories; -p indicates to create the whole path
mkdir -p $out_dir/run_logs
mkdir -p $out_dir/star_scripts

#the reads are in pairs in folders, iterate over each pair
for READ in A1 A2 A3 E1 E2 E3
        do
        #specify the input reads and output names
        R1=$READ'_1_trimmed.fastq.gz'
        R2=$READ'_2_trimmed.fastq.gz'
        R1_map=$READ'.bam'

#generate a unique slurm script for this pair
echo \
"#!/bin/bash -e
#SBATCH -p batch
#SBATCH -n 4
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH -o ./run_logs/star.%N.%j.out
#SBATCH -e ./run_logs/star.%N.%j.err
#SBATCH --mail-type=END,FAIL

#automatically loads star and samtools
module load module load star samtools
#create bam 
STAR --runThreadN 8 --runMode alignReads --genomeDir ./HISAT2_ref/ --readFilesCommand zcat --readFilesIn $read_dir/$R1 $read_dir/$R2 --outSAMtype BAM SortedByCoordinate --outSAMattrRGline ID:${READ} SM:${READ} --outFileNamePrefix ${READ} " > $out_dir/star_scripts/$READ'_star_slurm.sh'

sbatch $out_dir/star_scripts/$READ'_star_slurm.sh'
done

####
#samtools
samtools sort -n -o *_st_namesort.bam *.bam
for file in star_out/*.bam ; do echo "processing ${file}"; module load samtools; samtools sort -@ 10 -n -o ${file:9:5}'_st_namesort.bam' ${file}; done

samtools fixmate -m *_st_namesort.bam *_st_fixmate.bam
for file in *namesort.bam; do echo "processing ${file}"; samtools fixmate -@ 10 -m ${file} ${file:0:9}'fixmate.bam';done

samtools sort -o *_st_positionsort.bam *_st_fixmate.bam
for file in *fixmate.bam ; do echo "processing ${file}";  samtools sort -@ 10 -o ${file:0:9}'positionsort.bam' ${file}; done

samtools markdup -s -r *_st_positionsort.bam  *_st_rmdup.bam
for fil in *positionsort.bam; do echo "processing ${fil}"; samtools markdup -s -r ${fil} ${fil:0:9}'rmdup.bam' -@ 10; done

samtools merge -r merged.bam *_rmdup.bam -@ 10

samtools index -@ 10 Col_0_Ler_0_merged.bam