## https://github.com/griffithlab/rnaseq_tutorial 
mkdir Tutorial/Ref_seq Tutorial/Reads
cd Tutorial/Ref_seq
# human genome chromosome 22
wget http://genomedata.org/rnaseq-tutorial/fasta/GRCh38/chr22_with_ERCC92.fa

#bases on chromosome 22 correspond to repetitive elements
cat chr22_with_ERCC92.fa | perl -ne 'if ($_ =~ /\>22/){$chr22=1}; if ($_ =~ /\>ERCC/){$chr22=0}; if ($chr22){print "$_";}' > chr22_only.fa

the percentage of repetitive elements in the whole length 
cat chr22_only.fa | grep -v ">" | perl -ne 'chomp $_; $r+= $_ =~ tr/a/A/; $r += $_ =~ tr/c/C/; $r += $_ =~ tr/g/G/; $r += $_ =~ tr/t/T/; $l += length($_); if (eof){$p = sprintf("%.2f", ($r/$l)*100); print "\nrepeat bases = $r\ntotal bases = $l\npercent repeat bases = $p%\n\n"}'

# occurences of the EcoRI restriction site are present in the chromosome 22 sequence
cat chr22_only.fa | grep -v ">" | perl -ne 'chomp $_; $s = uc($_); print $_;' | perl -ne '$c += $_ =~ s/GAATTC/XXXXXX/g; if (eof){print "\nEcoRI site (GAATTC) count = $c\n\n";}'

#gene annotation files
wget http://genomedata.org/rnaseq-tutorial/annotations/GRCh38/chr22_with_ERCC92.gtf

#unique gene IDs are in the .gtf file
awk '/gene_id/ {print $10}' chr22_with_ERCC92.gtf |grep -o '[[:alpha:]]..............'| sort |uniq |wc -l
perl -ne 'if ($_ =~ /(gene_id\s\"ENSG\w+\")/){print "$1\n"}' chr22_with_ERCC92.gtf | sort | uniq | wc -l

# indexing with HISAT2
module load hisat2
hisat2_extract_splice_sites.py chr22_with_ERCC92.gtf > splicesites.tsv
hisat2_extract_exons.py chr22_with_ERCC92.gtf > exons.tsv
hisat2-build -p 16 --ss splicesites.tsv --exon exons.tsv chr22_with_ERCC92.fa chr22_with_ERCC92_index

#getting raw reads
# UHR + ERCC Spike-In Mix1, Replicate 1
# UHR + ERCC Spike-In Mix1, Replicate 2
# UHR + ERCC Spike-In Mix1, Replicate 3
# HBR + ERCC Spike-In Mix2, Replicate 1
# HBR + ERCC Spike-In Mix2, Replicate 2
# HBR + ERCC Spike-In Mix2, Replicate 3
# Each data set has a corresponding pair of FastQ files (read 1 and read 2 of paired end reads).
# The reads are paired-end 101-mers generated on an Illumina HiSeq instrument. The test data has been pre-filtered for reads that appear to map to chromosome 22

wget http://genomedata.org/rnaseq-tutorial/HBR_UHR_ERCC_ds_5pc.tar

#untar the file
tar -xvf HBR_UHR_ERCC_ds_5pc.tar

# fasqc
module load fastqc
fastqc -t 10 UHR_Rep1_ERCC-Mix1_Build37-ErccTranscripts-chr22.read1.fastq.gz

#trimming
#!/bin/bash

#specify paths to your working directory and your reads directory
wok_dir='/home/dkiambi/Desktop/tutorial_rev'    # the working directory with relevant files and folders
read_dir='/home/dkiambi/Desktop/tutorial_rev/Reads' 		# folder with reads

cd $wok_dir
#create an overall output directory
mkdir -p trim
out_dir=$wok_dir/trim					# location of output directory, created before

#make separate output directories within the overall output directories; -p indicates to create the whole path
mkdir -p $out_dir/run_logs
mkdir -p $out_dir/slurm_scripts
mkdir -p $out_dir/trimming_output

#the reads are in pairs in one folder, iterate over each pair
for READ in HBR_Rep1_ERCC-Mix2 HBR_Rep2_ERCC-Mix2 HBR_Rep3_ERCC-Mix2 UHR_Rep1_ERCC-Mix1 UHR_Rep2_ERCC-Mix1 UHR_Rep3_ERCC-Mix1 #pattern of files 
        do
        #specify the input reads and output names
        R1=$READ'_Build37-ErccTranscripts-chr22.read1.fastq.gz'   		
        R2=$READ'_Build37-ErccTranscripts-chr22.read2.fastq.gz'
        R1_trimmed=$READ'_1_trimmed.fastq.gz'
		R1_unpaired=$READ'_1_unpaired.fastq.gz'
		R2_trimmed=$READ'_2_trimmed.fastq.gz'
		R2_unpaired=$READ'_2_unpaired.fastq.gz'

#generate a unique slurm script for this pair
echo \
"#!/bin/bash -e
#SBATCH -p batch
#SBATCH --mail-user=D.Kaimenyi@cgiar.org      
#SBATCH -o $out_dir/run_logs/trim.$READ.%N.%j.out
#SBATCH -e $out_dir/run_logs/trim.$READ.%N.%j.err
#SBATCH --mail-type=END,FAIL

#automatically loads 0.38
module load trimmomatic
#PE for paired end
trimmomatic PE -threads 4 $read_dir/$R1 $read_dir/$R2 $out_dir/trimming_output/$R1_trimmed \
$out_dir/trimming_output/$R1_unpaired $out_dir/trimming_output/$R2_trimmed $out_dir/trimming_output/$R2_unpaired HEADCROP:10 TRAILING:3 SLIDINGWINDOW:4:28 AVGQUAL:28 \
" > $out_dir/slurm_scripts/$READ'_trimmomatic_slurm.sh'

sbatch $out_dir/slurm_scripts/$READ'_trimmomatic_slurm.sh'
done 
##
hisat2 -p 8 --rg-id=UHR_Rep1 --rg SM:UHR --rg LB:UHR_Rep1_ERCC-Mix1 --rg PL:ILLUMINA --rg PU:CXX1234-ACTGAC.1 -x $RNA_REF_INDEX --dta --rna-strandness RF -1 $RNA_DATA_DIR/UHR_Rep1_ERCC-Mix1_Build37-ErccTranscripts-chr22.read1.fastq.gz -2 $RNA_DATA_DIR/UHR_Rep1_ERCC-Mix1_Build37-ErccTranscripts-chr22.read2.fastq.gz -S ./UHR_Rep1.sam

#!/bin/bash

#specify paths to your working directory and your reads directory
wok_dir='/home/dkiambi/Desktop/tutorial_rev'    # the working directory with relevant files and folders
read_dir='/home/dkiambi/Desktop/tutorial_rev/trim/trimming_output' 		# folder with reads

cd $wok_dir
#create an overall output directory
out_dir=$wok_dir/mapping					# location of output directory, created before

#make separate output directories within the overall output directories; -p indicates to create the whole path
mkdir -p $out_dir/run_logs
mkdir -p $out_dir/slurm_scripts
mkdir -p $out_dir/map_output

#the reads are in pairs in one folder, iterate over each pair
for READ in HBR_Rep1_ERCC-Mix2 HBR_Rep2_ERCC-Mix2 HBR_Rep3_ERCC-Mix2 UHR_Rep1_ERCC-Mix1 UHR_Rep2_ERCC-Mix1 UHR_Rep3_ERCC-Mix1 # pattern of files 
        do
        #specify the input reads and output names
        R1=$READ'_1_trimmed.fastq.gz'
        R2=$READ'_2_trimmed.fastq.gz'
        R1_map=$READ'.bam'

#generate a unique slurm script for this pair
echo \
"#!/bin/bash -e
#SBATCH -p batch
#SBATCH --mail-user=D.Kaimenyi@cgiar.org      
#SBATCH -o $out_dir/run_logs/map.$READ.%N.%j.out
#SBATCH -e $out_dir/run_logs/map.$READ.%N.%j.err
#SBATCH --mail-type=END,FAIL

#automatically loads hisat2 and samtools
module load hisat2/2.0.5 
#create bam 
hisat2 --rg-id=${READ:0:8} --rg SM:${READ:0:3} --rg LB:$READ --rg PL:ILLUMINA -x Ref_seq/chr22_with_ERCC92_index -p 10 --dta --rna-strandness RF -1 $read_dir/$R1 -2 $read_dir/$R2 -S $out_dir/$R1_map " > $out_dir/slurm_scripts/$READ'_hisat_slurm.sh'

sbatch $out_dir/slurm_scripts/$READ'_hisat_slurm.sh'
done 

# samtool sort

for file in *.sam; do echo ${file}; samtools sort -@ 8 -o ${file:0:-3}'bam' ${file};done

#merge bam files
module load picard/2.8.2 samtools 
picard MergeSamFiles OUTPUT=UHR.bam INPUT=UHR_Rep1_ERCC-Mix1.bam INPUT=UHR_Rep2_ERCC-Mix1.bam INPUT=UHR_Rep3_ERCC-Mix1.bam
samtools merge -r merge_UHR.bam UHR_Rep* -@ 10

samtools merge -r merge_HBR.bam HBR_Rep* -@ 10
picard MergeSamFiles OUTPUT=HBR.bam INPUT=HBR_Rep1_ERCC-Mix2.bam INPUT=HBR_Rep2_ERCC-Mix2.bam INPUT=HBR_Rep3_ERCC-Mix2.bam
# indexing bam files 
for f in *.bam; do echo $f; samtools index -@ 10 $f $f'.bai';done
find *.bam -exec echo samtools index -@ 10 {} \; | sh
# indexing reference
samtools faidx chr22_with_ERCC92.fa

#create basic bed file
echo "22 38483683 38483683" > snvs.bed

bam-readcount -l snvs.bed -f Ref_seq/chr22_with_ERCC92.fa mapping/merge_UHR.bam 2>/dev/null 1>UHR_bam-readcounts.txt

cat UHR_bam-readcounts.txt | perl -ne '@data=split("\t", $_); @Adata=split(":", $data[5]); @Cdata=split(":", $data[6]); @Gdata=split(":", $data[7]); @Tdata=split(":", $data[8]); print "UHR Counts\t$data[0]\t$data[1]\tA: $Adata[1]\tC: $Cdata[1]\tT: $Tdata[1]\tG: $Gdata[1]\n";'

samtools flagstat UHR.bam

module load stringtie
stringtie -p 8 -G Ref_seq/chr22_with_ERCC92.gtf -e -B -o HBR_Rep1/transcripts.gtf -A HBR_Rep1/gene_abundances.tsv mapping/HBR_Rep1.bam

for file in mapping/*Rep*bam ; do echo ${file}; stringtie -p 8 -G Ref_seq/chr22_with_ERCC92.gtf -e -B -o ${file:8:8}/transcripts.gtf -A ${file:8:8}/gene_abundances.tsv ${file}; done

# view transcript records and their expression values (FPKM and TPM values)
awk '{if ($3=="transcript") print}' Stringtie/UHR_Rep1/transcripts.gtf | cut -f 1,4,9 | less

# tidy up expression matrix files for the StringTie results
wget https://raw.githubusercontent.com/griffithlab/rnaseq_tutorial/master/scripts/stringtie_expression_matrix.pl 

./stringtie_expression_matrix.pl --expression_metric=TPM --result_dirs='HBR_Rep1,HBR_Rep2,HBR_Rep3,UHR_Rep1,UHR_Rep2,UHR_Rep3' --transcript_matrix_file=transcript_tpm_all_samples.tsv --gene_matrix_file=gene_tpm_all_samples.tsv

./stringtie_expression_matrix.pl --expression_metric=FPKM --result_dirs='HBR_Rep1,HBR_Rep2,HBR_Rep3,UHR_Rep1,UHR_Rep2,UHR_Rep3' --transcript_matrix_file=transcript_fpkm_all_samples.tsv --gene_matrix_file=gene_fpkm_all_samples.tsv

./stringtie_expression_matrix.pl --expression_metric=Coverage --result_dirs='HBR_Rep1,HBR_Rep2,HBR_Rep3,UHR_Rep1,UHR_Rep2,UHR_Rep3' --transcript_matrix_file=transcript_coverage_all_samples.tsv --gene_matrix_file=gene_coverage_all_samples.tsv

head transcript_tpm_all_samples.tsv gene_tpm_all_samples.tsv
 #
 module load htseq/0.9.1
 htseq-count --format bam --order pos --mode intersection-strict --stranded reverse --minaqual 1 --type exon --idattr gene_id $RNA_ALIGN_DIR/UHR_Rep1.bam $RNA_REF_GTF > UHR_Rep1_gene.tsv
 
 for file in mapping/*Rep*bam ; do echo ${file}; htseq-count --format bam --order pos --mode intersection-strict --stranded reverse --minaqual 1 --type exon --idattr gene_id ${file} Ref_seq/chr22_with_ERCC92.gtf > htseq_out/${file:8:8}'gene.tsv'; done 
 
 # Merge results files into a single matrix for use in edgeR. 
 # The following joins the results for each replicate together, adds a header, reformats the result as a tab delimited file, and shows you the first 10 lines of the resulting file

join UHR_Rep1_gene.tsv UHR_Rep2_gene.tsv | join - UHR_Rep3_gene.tsv | join - HBR_Rep1_gene.tsv | join - HBR_Rep2_gene.tsv | join - HBR_Rep3_gene.tsv > gene_read_counts_table_all.tsv
echo "GeneID UHR_Rep1 UHR_Rep2 UHR_Rep3 HBR_Rep1 HBR_Rep2 HBR_Rep3" > header.txt
cat header.txt gene_read_counts_table_all.tsv | grep -v "__" | perl -ne 'chomp $_; $_ =~ s/\s+/\t/g; print "$_\n"' > gene_read_counts_table_all_final.tsv
rm -f gene_read_counts_table_all.tsv header.txt
head gene_read_counts_table_all_final.tsv

# download a file describing the expected concentrations and fold-change differences for the ERCC spike-in reagent
wget http://genomedata.org/rnaseq-tutorial/ERCC_Controls_Analysis.txt
 
# Perl script to organize the ERCC expected values and our observed counts for each ERCC sequence
wget https://raw.githubusercontent.com/griffithlab/rnaseq_tutorial/master/scripts/Tutorial_ERCC_expression.pl
chmod 755 Tutorial_ERCC_expression.pl
chmod +x Tutorial_ERCC_expression.pl
./Tutorial_ERCC_expression.pl
less ercc_read_counts.tsv

# R script to produce an x-y scatter plot that compares the expected and observed values
wget https://raw.githubusercontent.com/griffithlab/rnaseq_tutorial/master/scripts/Tutorial_ERCC_expression.R
chmod +x Tutorial_ERCC_expression.R

#  create a file that lists our 6 expression files, then view that file
printf "\"ids\",\"type\",\"path\"\n\"UHR_Rep1\",\"UHR\",\"$RNA_HOME/expression/stringtie/ref_only/UHR_Rep1\"\n\"UHR_Rep2\",\"UHR\",\"$RNA_HOME/expression/stringtie/ref_only/UHR_Rep2\"\n\"UHR_Rep3\",\"UHR\",\"$RNA_HOME/expression/stringtie/ref_only/UHR_Rep3\"\n\"HBR_Rep1\",\"HBR\",\"$RNA_HOME/expression/stringtie/ref_only/HBR_Rep1\"\n\"HBR_Rep2\",\"HBR\",\"$RNA_HOME/expression/stringtie/ref_only/HBR_Rep2\"\n\"HBR_Rep3\",\"HBR\",\"$RNA_HOME/expression/stringtie/ref_only/HBR_Rep3\"\n" > UHR_vs_HBR.csv
cat UHR_vs_HBR.csv

##
# R ballgpwn tutuorial
##
head UHR_vs_HBR_gene_results.tsv

# count of features
grep -v feature UHR_vs_HBR_gene_results.tsv | wc -l

# passed filter in UHR or HBR
grep -v feature UHR_vs_HBR_gene_results_filtered.tsv | wc -l

# How many differentially expressed genes were found on this chromosome
grep -v feature UHR_vs_HBR_gene_results_sig.tsv | wc -l

grep -v feature UHR_vs_HBR_gene_results_sig.tsv | sort -rnk 3 | head -n 20 #Higher abundance in UHR
grep -v feature UHR_vs_HBR_gene_results_sig.tsv | sort -nk 3 | head -n 20 #Higher abundance in HBR

# all genes with P<0.05 to a new file
grep -v feature UHR_vs_HBR_gene_results_sig.tsv | cut -f 6 | sed 's/\"//g' > DE_genes.txt

# Create a mapping file to go from ENSG IDs (which htseq-count output) to Symbols
perl -ne 'if ($_ =~ /gene_id\s\"(ENSG\S+)\"\;/) { $id = $1; $name = undef; if ($_ =~ /gene_name\s\"(\S+)"\;/) { $name = $1; }; }; if ($id && $name) {print "$id\t$name\n";} if ($_=~/gene_id\s\"(ERCC\S+)\"/){print "$1\t$1\n";}' ../Ref_seq/chr22_with_ERCC92.gtf

for f in DE*txt ;do echo ${f}; cut -f 1 ${f} | sort > 'new_'${f};done