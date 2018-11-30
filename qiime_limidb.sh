# test if this will work
wget -O -  "http://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?save=efetch&rettype=runinfo&db=sra&term=PRJNA223640" | cut -d ',' -f 1 | grep -v '^$' |while read A; do  fastq-dump $A ; done

sed -i 's/forward/reverse/g' sheep_wa/manifest # replace all
for f in $(ls *.csv); do echo $f ;sed 's/,/\t/g' $f > ${f%%.csv}'.tsv' ;done #change all csv files to tsv 
qiime tools import --type 'SampleData[SequencesWithQuality]' --input-path $PWD/manifest --output-path $PWD/se.qza --source-format SingleEndFastqManifestPhred33
qiime metadata tabulate --m-input-file metadata.tsv --o-visualization metadata.qzv

# uncomment where relevant

#!/bin/bash

#specify paths to your working directory and your reads directory
WORKING_DIR='/home/dkiambi/Qiime2_limidb/raw_reads/'

cd $WORKING_DIR

#the reads are in pairs in folders, iterate over each pair
for file in $(ls -I "*.sh" -I "*.txt" -I "*.out" -I "cow_meth" -I "scot_cow_meth" -I "can_cow" -I "gg*" -I "buff_gut" -I "chick_micr" -I "ref*")
	do
	
	OUTPUT_DIR=${file}/fastq_out
#generate a unique slurm script for ec folder	
echo \
"#!/bin/bash -e
#SBATCH -p batch 
#SBATCH -n 2     
#SBATCH -o $OUTPUT_DIR/qiime2.%N.%j.out 
#SBATCH -e $OUTPUT_DIR/qiime2.%N.%j.err
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH --mail-type=END,FAIL

# automatically load module qiime2

module load qiime2

# import the data into the qiime 2 env using the manifest file created above
#qiime tools import --type 'SampleData[SequencesWithQuality]' --input-path ${file}/manifest --output-path ${file}/${file}'_single.qza' --source-format SingleEndFastqManifestPhred33

# import the metadata into the qiime 2 env 
#qiime metadata tabulate --m-input-file ${file}/metadata.tsv --o-visualization ${file}/metadata.qzv

# generate a summary of the artifact
#qiime demux summarize --i-data ${file}/${file}'_single.qza' --o-visualization ${file}/${file}'_demux_reads.qzv'

#qiime dada2 denoise-single --i-demultiplexed-seqs ${file}/${file}'_single.qza' --p-trim-left 5 --p-trunc-len 200 --o-representative-sequences rep-seqs-dada2.qza --o-table #table-dada2.qza --o-denoising-stats stats-dada2.qza

# building visualizations:
qiime metadata tabulate --m-input-file ${file}/${file}'_stats-dada2.qza' --o-visualization ${file}/${file}'_stats-dada2.qzv'

qiime feature-table summarize --i-table ${file}/${file}'_table-dada2.qza' --o-visualization ${file}/${file}'_table-dada2.qzv'

# then build the visualisation for the representative sequences:
qiime feature-table tabulate-seqs --i-data ${file}/${file}'_rep-seqs-dada2.qza' --o-visualization ${file}/${file}'_rep-seqs-dada2.qzv'

# assign taxonomy to your sequences
qiime feature-classifier classify-sklearn --i-classifier ${WORKING_DIR}/gg_classifier.qza --i-reads ${file}/${file}'_rep-seqs-dada2.qza' --o-classification ${file}/${file}'_taxonomy.qza'

qiime metadata tabulate --m-input-file ${file}/${file}'_taxonomy.qza' --o-visualization ${file}/${file}'_taxonomy.qzv'

#getting feature biom file
qiime tools export ${file}/${file}'_table-dada2.qza' --output-dir ${file}/

# convert it to tsv and view it
biom convert -i ${file}/feature-table.biom -o ${file}/feature-table.tsv --to-tsv

#getting taxonomy biom file 
qiime tools export ${file}/${file}'_taxonomy.qza' --output-dir ${file}/ # the output is a tsv

" > $OUTPUT_DIR/$file'_qiime2_slurm.sh'
sbatch $OUTPUT_DIR/$file'_qiime2_slurm.sh'
done


######
# do this for each of the folders

#!/bin/bash -e
#SBATCH -p batch 
#SBATCH -n 4     
#SBATCH -o /home/dkiambi/Qiime2_limidb/raw_reads/can_cow/qiime2.%N.%j.out 
#SBATCH -e /home/dkiambi/Qiime2_limidb/raw_reads/buff_gut/qiime2.%N.%j.err
#SBATCH --mail-user=D.Kaimenyi@cgiar.org
#SBATCH --mail-type=END,FAIL

# automatically load module qiime2

module load qiime2

qiime dada2 denoise-single --i-demultiplexed-seqs /home/dkiambi/Qiime2_limidb/raw_reads/buff_gut/buff_gut_single.qza --p-trim-left 1 --p-trunc-len 377 --o-representative-sequences /home/dkiambi/Qiime2_limidb/raw_reads/buff_gut/buff_gut_rep-seqs-dada2.qza --o-table /home/dkiambi/Qiime2_limidb/raw_reads/buff_gut/buff_gut_table-dada2.qza --o-denoising-stats /home/dkiambi/Qiime2_limidb/raw_reads/buff_gut/buff_gut_stats-dada2.qza
###

# training the classifier
wget ftp://greengenes.microbio.me/greengenes_release/gg_13_5/gg_13_8_otus.tar.gz # most recent vreion of greengenes database

tar -xzf gg_13_8_otus.tar.gz
######

qiime tools import --type 'FeatureData[Sequence]' --input-path /home/dkiambi/Qiime2_limidb/raw_reads/gg_13_5_otus/rep_set/99_otus.fasta --output-path /home/dkiambi/Qiime2_limidb/raw_reads/gg_99_otu_map.qza

qiime tools import --type 'FeatureData[Taxonomy]' --source-format HeaderlessTSVTaxonomyFormat --input-path /home/dkiambi/Qiime2_limidb/raw_reads/gg_13_5_otus/taxonomy/99_otu_taxonomy.txt --output-path /home/dkiambi/Qiime2_limidb/raw_reads/ref-taxonomy.qza

qiime feature-classifier fit-classifier-naive-bayes --i-reference-reads /home/dkiambi/Qiime2_limidb/raw_reads/gg_99_otu_map.qza --i-reference-taxonomy /home/dkiambi/Qiime2_limidb/raw_reads/ref-taxonomy.qza --o-classifier /home/dkiambi/Qiime2_limidb/raw_reads/gg_classifier.qza

qiime feature-classifier classify-sklearn --i-classifier gg_classifier.qza --i-reads rep-seqs.qza --o-classification taxonomy.qza

qiime metadata tabulate --m-input-file taxonomy.qza --o-visualization taxonomy.qzv

### converting to tsv
qiime tools export table.qza --output-dir ./
biom convert -i feature-table.biom -o feature-table.tsv --to-tsv
qiime tools export table.qza --output-dir exported
qiime tools export taxonomy.qza --output-dir exported

# building visualizations:
qiime metadata tabulate --m-input-file bovine_micr/bovine_micr'_stats-dada2.qza' --o-visualization bovine_micr/bovine_micr'_stats-dada2.qzv'

qiime feature-table summarize --i-table bovine_micr/bovine_micr'_table-dada2.qza' --o-visualization bovine_micr/bovine_micr'_table-dada2.qzv'

# then build the visualisation for the representative sequences:
qiime feature-table tabulate-seqs --i-data bovine_micr/bovine_micr'_rep-seqs-dada2.qza' --o-visualization bovine_micr/bovine_micr'_rep-seqs-dada2.qzv'

# assign taxonomy to your sequences
qiime feature-classifier classify-sklearn --i-classifier /home/dkiambi/Qiime2_limidb/raw_reads/gg_classifier.qza --i-reads bovine_micr/bovine_micr'_rep-seqs-dada2.qza' --o-classification bovine_micr/bovine_micr'_taxonomy.qza'

qiime metadata tabulate --m-input-file bovine_micr/bovine_micr'_taxonomy.qza' --o-visualization bovine_micr/bovine_micr'_taxonomy.qzv'

#getting feature biom file
qiime tools export bovine_micr/bovine_micr'_table-dada2.qza' --output-dir bovine_micr/

# convert it to tsv and view it
biom convert -i bovine_micr/feature-table.biom -o bovine_micr/feature-table.tsv --to-tsv

#getting taxonomy biom file
qiime tools export bovine_micr/bovine_micr'_taxonomy.qza' --output-dir bovine_micr/ # the output is a tsv


