##Wed_13_06
#copy all bash scripts into one folder
for i in $(find ./ -type f -name "*.sh"); do echo ${i}; cp ${i} ./Scripts/;done
# set the script folder as a git repo
git init
git add . 
git commit -m "initial commit for all bash files"
#set up new repo in git
git remote add origin https://github.com/davekk/Bash_scripts.git
# Verifies the new remote URL
git remote -v
git push origin master
#
### sort bam file 
samtools sort -n -o CS_DF5_st_namesort.bam sorted_DF5_P.bam
# loop over all bam files
for file in *.bam; do echo "processing ${file}"; samtools sort -n -o 'CS_'${file:7:-5}'st_namesort.bam' ${file} -@ 10 ;done

# remove duplicates while ttaching mate scores to the bam file
samtools fixmate -m CS_DF5_st_namesort.bam CS_DF5_st_fixmate.bam
# loop over all sorted bams
for fil in *namesort.bam; do echo "processing ${fil}"; samtools fixmate -m ${fil} ${fil:0:-12}'fixmate.bam' -@ 10; done 

# sort the bam files again
samtools sort -o CS_DF5_st_positionsort.bam CS_DF5_st_fixmate.bam
# loop
for file in *fixmate.bam; do echo "processing ${file}"; samtools sort -o ${file:0:-11}'positionsort.bam' ${file} -@ 10 ;done

# mark and remove duplicate reads
samtools markdup -s -r CS_DF5_st_positionsort.bam  CS_DF5_st_rmdup.bam
for fil in *positionsort.bam; do echo "processing ${fil}"; samtools markdup -s -r ${fil} ${fil:0:-16}'rmdup.bam' -@ 10; done
# save stat to txt file
for fil in *positionsort.bam; do echo "processing ${fil}" >>stat_pos.txt; samtools markdup -s -r ${fil} ${fil:0:-16}'rmdup.bam' -@ 10 >>stat_pos.txt; done

# view the top of file
samtools view CS_DF5_st_rmdup.bam | head
# loop
for file in *.bam; do echo ${file}; samtools view ${file} | head | less -S; done

# merging the rmdup files
samtools merge -r merged.bam *_rmdup.bam -@ 10
# adding a header to the merged file
samtools view -@ 10 -H merged.bam > merged_header.txt

# add the text below t the bottom of the header file
@RG	ID:CS_DF5_st_rmdup	SM:CS_DF5	LB:LIB1	PL:Illumina
@RG	ID:CS_DF19_st_rmdup	SM:CS_DF19	LB:LIB2	PL:Illumina
@RG	ID:CS_119B_st_rmdup	SM:CS_119B	LB:LIB3	PL:Illumina
@RG	ID:CS_120A_st_rmdup	SM:CS_120A	LB:LIB4	PL:Illumina

# reheader the bam file
samtools reheader merged_header.txt merged.bam > merged_readgroups.bam
#Check that the header was applied properly
samtools view -H merged_readgroups.bam
# index the bam file for quick retrival in downstream analysis
samtools index merged_readgroups.bam -@ 10

# load ing freebayes
module load freebayes/1.0.2

# run FreeBayes on the alignments of all 4 samples simultaneously and generate a VCF file
freebayes --fasta-reference /var/scratch/baileyp/Practical_4_RicardosExample/References/transformed_coordinates.fasta \
merged_readgroups.bam > all_snps.vcf &

#call SNPs on chr1A
freebayes -r chr1A --fasta-reference /var/scratch/baileyp/Practical_4_RicardosExample/References/transformed_coordinates.fasta \
merged_readgroups.bam > chr1A_snps.vcf &

# finding number of chromosomes in fasta file
grep '>' /var/scratch/baileyp/Practical_4_RicardosExample/References/transformed_coordinates.fasta
# calling snips for all chromosomes singly 
for hat in $(grep '>' /var/scratch/baileyp/Practical_4_RicardosExample/References/transformed_coordinates.fasta); do echo ${hat}; \
freebayes -r ${hat:1:5} --fasta-reference /var/scratch/baileyp/Practical_4_RicardosExample/References/transformed_coordinates.fasta \
merged_readgroups.bam > ${hat:1:5}'_snps.vcf';done

## variant calling processing
module load vcftools/0.1.15
# remove snp of <20 quality score, < 6 min depth, indels and max missing position a and write ro new vcf  
vcftools --vcf all_snps.vcf --recode --recode-INFO-all --minQ 20 --minDP 6 --remove-indels --max-missing 1 --out all_min20_mindp6_no_idel_max_miss

# simple summary of all Transitions and Transversions
vcftools --vcf all_snps.vcf --minQ 20 --minDP 6 --remove-indels --max-missing 1  --TsTv-summary

# Transition / Transversion ratio as a function of alternative allele count
vcftools --vcf all_snps.vcf --minQ 20 --minDP 6 --remove-indels --max-missing 1  --TsTv-by-count

# module load snpeff/4.1g 
snpEff -c /var/scratch/baileyp/Practical_4_small_wheat_dataset/snpEff/snpEff.config refseq_mini all_min20_mindp6_no_idel_max_miss.recode.vcf \
> all_minQ20_minDP6_noindels_maxm1_snpeff.vcf

### thursday arabidopsis
module load star/2.5.2b trimmomatic/0.38 samtools/1.8

STAR --runThreadN 10 --runMode  genomeGenerate --genomeDir  ./ --genomeFastaFiles  Arabidopsis_thaliana.TAIR10.dna.toplevel.fa \
--sjdbGTFfile  Arabidopsis_thaliana.TAIR10.39.gtf --sjdbOverhang 77

# converting files from phred 64 to phred 33
sed -e '4~4y/@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghi/!"#$%&'\''()*+,-.\/0123456789:;<=>?@ABCDEFGHIJ/' \
/var/scratch/baileyp/Practical_5_Arabidopsis_accns/fastq_files/R38_L1_Col_0_sdlg_R1_nss_barcode_GTA.fastq \
> Col_0_R1_Phred33.fastq

# loop for col-0 reads
for file in /var/scratch/baileyp/Practical_5_Arabidopsis_accns/fastq_files/*Col*A.fa* ; do echo "processing ${file}"; sed -e \
'4~4y/@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghi/!"#$%&'\''()*+,-.\/0123456789:;<=>?@ABCDEFGHIJ/' ${file} > ./fastq_arab/${file:70:-22}'Phred33.fastq';done
# loop for ler-0 reads
for file in /var/scratch/baileyp/Practical_5_Arabidopsis_accns/fastq_files/*Ler*C.fa* ; do echo "processing ${file}"; sed -e \
'4~4y/@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghi/!"#$%&'\''()*+,-.\/0123456789:;<=>?@ABCDEFGHIJ/' ${file} > ./fastq_arab/${file:70:-22}'Phred33.fastq';done

# trimmomatic 
At_accn=Col_0 	# Col_0 Ler_0
cpu=10
trimmomatic SE -threads $cpu -phred33 -trimlog ${At_accn}_R1_trimmomatic.log Col_0_R1_Phred33.fastq ${At_accn}_R1_trimmomatic.fq.gz LEADING:1 \
TRAILING:1 SLIDINGWINDOW:5:18 MINLEN:36 MINLEN:36 > ${At_accn}_R1_trimmomatic.log 2>&1 &
#loop 
for fig in fastq_arab/*R1* ; do echo ${fig}; module load trimmomatic/0.38; trimmomatic SE -threads 10 -phred33 -trimlog ${fig:11:-13}'trimmomatic.log' ${fig} ${fig:11:-13}'trimmomatic.fq.gz' LEADING:1 TRAILING:1 SLIDINGWINDOW:5:18 MINLEN:36 ;done 

#star alligner
STAR --runThreadN 4 --runMode alignReads --genomeDir ./Arab_ref/ --readFilesCommand zcat --readFilesIn {$At_accn}_R1_trimmomatic.fq.gz --outSAMtype BAM SortedByCoordinate --outSAMattrRGline ID:$At_accn SM:$At_accn --outFileNamePrefix ${At_accn}
# loop 
for fil in *tic.fq.gz; do echo "processing ${fil}"; STAR --runThreadN 16 --runMode alignReads --genomeDir ./Arab_ref/ --readFilesCommand zcat --readFilesIn ${fil} --outSAMtype BAM SortedByCoordinate --outSAMattrRGline ID:${fil:0:5} SM:${fil:0:5} --outFileNamePrefix ${fil:0:5};done

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
# freebayes 
module load freebayes/1.0.2
freebayes --fasta-reference Arabidopsis_thaliana.TAIR10.dna.toplevel.fa Col_0_Ler_0_merged.bam -r 4 > merged_chr4_ONLY.vcf &
freebayes --fasta-reference ./Arab_ref/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa ./star_out/Col_0_Ler_0_merged.bam > merged_col_ler.vcf &
# vcf tools
module load vcftools/0.1.15
vcftools --vcf merged_chr4_ONLY.vcf --recode --recode-INFO-all --minQ 20 --minDP 6 --remove-indels --max-missing 1 --out chr4_ONLY_minQ20_minDP6_noindels_maxm1
vcftools --vcf merged_col_ler.vcf --recode --recode-INFO-all --minQ 20 --minDP 6 --remove-indels --max-missing 1 --out col_ler_ONLY_minQ20_minDP6_noindels_maxm1
# snpEff
module load snpeff/4.1g
snpEff -c /var/scratch/baileyp/Practical_5_Arabidopsis_accns/snpEff/snpEff.config athalianaTair10 chr4_ONLY_minQ20_minDP6_noindels_maxm1.recode.vcf > chr4_ONLY_filtered_snpeff.vcf
 for file in *.vcf do echo "processing ${file}"; snpEff -c /var/scratch/baileyp/Practical_5_Arabidopsis_accns/snpEff/snpEff.config athalianaTair10\
 ${file} > ${file:0:-28}'filtered_snpeff.vcf'
 
 ## scp
 scp -r dkiambi@taurus.ilri.cgiar.org:/var/scratch/dkiambi/Mod_4_Data/module4_RNAseq/alignments_kallisto/* .
