module load tassel/5.2.9 # /5.2.14 works better

# takes fastQ files as input, identifies tags and the taxa in which they appear, and stores this data to a local database
run_pipeline.pl -Xms15G -Xmx15G \ # ram size control
-fork1 -GBSSeqToTagDBPlugin \# forking threading and gbs to tag conversion
-e ApeKI -i ../tassel_example/fastq \ # enzyme tag for re used and input file
-db rice_example.db -k ../tassel_example/key/D0DTNACXX_1-key-file.tsv \ # name of db to be created and key file as a tsv
-mxTagL 64 -mnTagL 50 -mnQS 20 -mxTagNum 300000000 -endPlugin -runfork1 > rice_example.out # kmer/tag control parameters

# retrieves distinct tags stored in the database and reformats them to a FASTQ file that can be read by the Bowtie2
run_pipeline.pl -Xms15G -Xmx15G -fork1 -TagExportToFastqPlugin \
-db rice_example.db -o rice_example.fastq.gz \ # db to use for tag export and output file
-c 10 -endPlugin -runfork1 >> rice_example.out # -c minimum number of tags count to be exported

# align with bowtie2 aligner
bowtie2 --end-to-end -x ../tassel_example/reference/Osativa_Reference.fa -U rice_example.fa.gz -S rice_example.sam -p 16 >>rice_example.out

# reads a SAM file to determine the potential positions of Tags against the reference genome. The plugin updates the current database with information on tag cut positions
run_pipeline.pl -Xms15G -Xmx15G -fork1 -SAMToGBSdbPlugin -i rice_example.sam -db rice_example.db -aProp 0.0 -aLen 0 -endPlugin -runfork1 >> rice_example.out

# takes a GBSv2 database file as input and identifies SNPs from the aligned tags. Tags positioned at the same physical location are aligned against one another, SNPs are called from the aligned tags, and the SNP position and allele data are written to the database.
run_pipeline.pl -Xms15G -Xmx15G -fork1 -DiscoverySNPCallerPluginV2 -db rice_example.db -mnLCov 0.1 -mnMAF 0.05 -deleteOldData true -endPlugin -runfork1 >> rice_example.out

#  scores all discovered SNPs for various coverage, depth and genotypic statistics for a given set of taxa. If no taxa are specified, the plugin will score all taxa currently stored in the data base
run_pipeline.pl -Xms15G -Xmx15G -fork1 -SNPQualityProfilerPlugin -db rice_example.db -statFile rice_snpfile.txt -endPlugin -runfork1 >> rice_example.out

# reads a quality score file to obtain quality score data for positions stored in the snpposition table. The quality score file is a user created file that supplies quality scores for SNP positions. It is up to the user to determine what values should be associated with each SNP. SNPQualityProfilerPlugin output provides data for this analysis
run_pipeline.pl -Xms15G -Xmx15G -fork1 -UpdateSNPPositionQualityPlugin -db rice_example.db -qsFile rice_snpfile.txt -endPlugin -runfork1 >> rice_example.out

# converts data from fastq and keyfile to genotypes, then adds these to a genotype file in VCF
run_pipeline.pl -Xms15G -Xmx15G -fork1 -ProductionSNPCallerPluginV2 -db rice_example.db -e ApeKI -i ../tassel_example/fastq -k ../tassel_example/key/D0DTNACXX_1-key-file.tsv -kmerLength 64 -o rice_example.h5 -endPlugin -runfork1 >> rice_example.out

# converting vcf to h5
# cp rice_example.vcf rice_example.h5

# 
run_pipeline.pl -Xms15G -Xmx15G -h5 rice_example.h5 -export rice_example.hmp.txt -exportType Hapmap

#
module load vcftools/0.1.15
# remove indels
vcftools --vcf rice_example.vcf --recode --recode-INFO-all --remove-indels --out rice_filtered
# rename to remove recode 
mv rice_filtered2.recode.vcf rice_filtered2.vcf
# filter to make sure all calls have a mn and max value of 2 alleles
vcftools --vcf rice_filtered.vcf --recode --recode-INFO-all --min-alleles 2 max-alleles 2  --out rice_filtered2

# filter based on minor allele frequency of 0.05
vcftools --vcf rice_filtered2.vcf --recode --recode-INFO-all --maf 0.05 --out rice_filtered3

# min read depth filter
vcftools --vcf rice_filtered3.vcf --recode --recode-INFO-all --minDP 2  --out rice_filtered4

# filter mising genotype values greater than 70%
vcftools --vcf rice_filtered4.vcf --recode --recode-INFO-all --max-missing 0.3 --out rice_filtered5

# full filter command
vcftools --vcf rice_example.vcf --remove-indels --min-alleles 2 --max-alleles 2 --minDP 2 --max-missing 0.3 --maf 0.05 --recode --recode-INFO-all --out rice_filtered_fresh

 # convert the filtered vcf to hapmap
../tassel_example/TASSEL_Software/tassel-5-standalone/run_pipeline.pl -vcf rice_filtered_final.vcf -export Hapmap >>rice_example.out


###
#working with tassel 3
# create working dir
/var/scratch/tassel_example/TASSEL_Software/tassel3-standalone/run_pipeline.pl -Xms20G -Xmx20G -fork1 -UCreatWorkingDirPlugin -w . -endPlugin -runfork1

../tassel_example/wheat/key/
../tassel_example/wheat/Illumina/

/var/scratch/tassel_example/TASSEL_Software/tassel3-standalone/run_pipeline.pl -Xms20G -Xmx20G -fork1 -UFastqToTagCountPlugin -w . -e PstI-MspI -s 500000000 -c 1 -endPlugin -runfork1


####
# Jared Crain Tassel workthrough
TASSEL 3 UNEAK Pipeline
#Step 1 create working directories
${TASSEL3} -Xms30G -Xmx30G -fork1 -UCreatWorkingDirPlugin  -w ${WORKDIR} -endPlugin -runfork1

#This creates working directores, once the key and fastq files are entered in the directories, the user does not have to specify paths to files.

#Step 2
#copy fastq file and key into respective directories
cp /home/jcrain/examples/wheat/fastq/*.txt.gz $WORKDIR/Illumina/
cp /home/jcrain/examples/wheat/SynOpDH_UNEAK_Key_Multiple_Fastq.txt $WORKDIR/key/

#This adds the key file and fastq files to the directories created in step 1.


#Step 3 Make tag count file
${TASSEL3} -Xms30G -Xmx30G -fork1 -UFastqToTagCountPlugin -w ${WORKDIR} -e PstI-MspI -s 500000000 -c 1 -endPlugin -runfork1

#This command makes a a tagcount file for each individual by counting the number of tags/sequences that had the barcode for the individual.

#Step 4 Make master tag count file 
${TASSEL3} -Xms30G -Xmx30G -fork1 -UMergeTaxaTagCountPlugin -w ${WORKDIR} -c 5  -m 1000000000 -x 10000000 -endPlugin -runfork1

#This command merges the tag count files into one file.

#Step 5
${TASSEL3} -Xms30G -Xmx30G -fork1 -UTagCountToTagPairPlugin -w ${WORKDIR} -e 0.03 -endPlugin -runfork1

########Generate Tags by Taxa TBT file###############     
${TASSEL3} -Xms30G -Xmx30G -fork1 -UTagPairToTBTPlugin -w ${WORKDIR} -endPlugin -runfork1

#This command creates the tags/sequences per individual in the key file.

######Generate map info file #####################
${TASSEL3} -Xms30G -Xmx30G -fork1 -UTBTToMapInfoPlugin -w ${WORKDIR} -endPlugin -runfork1

#this command generated the map information data.
     
##########Generate HapMap file ###############
${TASSEL3} -Xms30G -Xmx30G -fork1 -UMapInfoToHapMapPlugin -w ${WORKDIR}{WtaORKDIR} -mnMAF 0.05 -mxMAF 0.5     -mnC 0  -mxC 1 -endPlugin -runfork1

#this command generates the hap files, depth count files, and fasta file of the SNPs.

 
# TASSEL V GBSv2 Pipeline:

#Step 1
#have to request memory but aslo specify it calling the plugin

## GBSSeqToTagDBPlugin  - RUN Tags to DB  require min quality score, 50 base pair tags, and up to 250M kmers in the database
$TASSEL -Xms20G -Xmx20G -fork1 -GBSSeqToTagDBPlugin -e ApeKI \
    -i $SEQUENCE \
    -db ${NAME}.db \
    -k ${KEYFILE} \
    -kmerLength 64 -minKmerL 50 -mnQS 20 -mxKmerNum 250000000 \
    -endPlugin -runfork1 >> ${NAME}_pipeline.out

#Builds a database of unique tags found in fastq files.

#Step 2
## TagExportToFastqPlugin  - export Tags to align to reference
$TASSEL -fork1 -TagExportToFastqPlugin \
    -db ${NAME}.db \
    -o ${NAME}_tagsForAlign.fa.gz -c 10 \
    -endPlugin -runfork1 >> ${NAME}_pipeline.out

#Export tags to align to the reference genome.
    
#Step 3
## RUN BOWTIE #-S is write to SAM file -U is unparied reads to be aligned -x is aligned files
bowtie2 --end-to-end  \
    -x ${REFERENCE} \
    -U ${NAME}_tagsForAlign.fa.gz \
    -S ${NAME}.sam >> ${NAME}_pipeline.out

#Align the tags.
    
#Step 4  
## SAMToGBSdbPlugin - SAM to DB, update database with alignment information
$TASSEL -Xms20G -Xmx20G -fork1 -SAMToGBSdbPlugin \
    -i ${NAME}.sam \
    -db ${NAME}.db \
    -aProp 0.0 -aLen 0 \
    -endPlugin -runfork1 >> ${NAME}_pipeline.out

#Update the database with sequence information for the tags.

#Step 5
## DiscoverySNPCaller
$TASSEL -Xms20G -Xmx20G -fork1 -DiscoverySNPCallerPluginV2 \
    -db ${NAME}.db \
    -mnLCov 0.1 -mnMAF 0.01 -deleteOldData true \
     -endPlugin -runfork1 >> ${NAME}_pipeline.out

#Identify SNPs within the database.
  
#Step 6  
## SNPQualityProfilerPlugin - RUN QUALITY PROFILER
$TASSEL -Xms20G -Xmx20G -fork1 -SNPQualityProfilerPlugin \
    -db ${NAME}.db \
    -statFile ${NAME}_SNPqual_stats.txt \
    -endPlugin -runfork1 >> ${NAME}_pipeline.out

#Get SNP quality information.
  
#Step 7    
## UpdateSNPPositionQualityPlugin - UPDATE DATABASE WITH QUALITY SCORE fast < 30 minutes 15GB
$TASSEL -Xms20G -Xmx20G -fork1 -UpdateSNPPositionQualityPlugin \
    -db ${NAME}.db \
    -qsFile ${NAME}_SNPqual_stats.txt \
    -endPlugin -runfork1 >> ${NAME}_pipeline.out

#Update the database with SNP quality information.

#Ends SNP discovery with database
#Use Production SNP caller to get SNPs and filter
#Step 8    
## ProductionSNPCallerPluginV2 - RUN PRODUCTION PIPELINE - output .vcf
$TASSEL -Xms20G -Xmx20G -fork1 -ProductionSNPCallerPluginV2 \
    -db ${NAME}.db \
    -i ${SEQUENCE} \
    -k ${KEYFILE} \
    -o ${NAME}.vcf \
    -e ApeKI -kmerLength 64 \
    -endPlugin -runfork1 >>  ${NAME}_pipeline.out 

#Run the production SNP caller.
    
#Step 9 ## Convert to Hapmap format
$TASSEL -Xms20G -Xmx20G -fork1 -vcf ${NAME}.vcf \
	-export ${NAME} -exportType Hapmap >>  ${NAME}_pipeline.out 

#Converts VCF file into hapmap file.
	
	
##Step 10 #clean up
#make sure to remove unneeded files other files and compress the vcf file	
	
 

