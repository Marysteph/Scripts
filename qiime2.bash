#create this manifest file with vim conatining absolute filepath to the sequences and their orientation
sample-id,absolute-filepath,direction
# Lines starting with '#' are ignored and can be used to create
# "comments" or even "comment out" entries
sample-1,/home/dkiambi/qiime2_tuto/data/S20_S20_L001_R1_001.fastq,forward
sample-2,/home/dkiambi/qiime2_tuto/data/S27_S27_L001_R1_001.fastq,forward
sample-1,/home/dkiambi/qiime2_tuto/data/S20_S20_L001_R2_001.fastq,reverse
sample-2,/home/dkiambi/qiime2_tuto/data/S27_S27_L001_R2_001.fastq,reverse
## end of file


# import the data into the qiime 2 env using the manifest file created above
qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path $PWD/manifest --output-path $PWD/paired.qza --source-format PairedEndFastqManifestPhred33

# # join the paired ends
qiime vsearch join-pairs --i-demultiplexed-seqs paired.qza --o-joined-sequences jioned_paired.qza

# generate a summary of the jioned_paired.qza artifact
qiime demux summarize --i-data jioned_paired.qza --o-visualization demux-joined.qzv

# quality control to our sequences
qiime quality-filter q-score-joined --i-demux jioned_paired.qza --o-filtered-sequences jioned_paired_filtered.qza --o-filter-stats jioned_paired_filter-stats.qza

# do one of the 2 step below their output is similar; the do the same thing 

# denoise your sequences with Dada2
qiime dada2 denoise-paired --i-demultiplexed-seqs paired.qza --o-table table.qza --p-trunc-len-f 150 --p-trunc-len-r 150 --o-representative-sequences rep-seqs.qza --o-denoising-stats denoising-stats.qza

# denoise in deblur 
qiime deblur denoise-16S --i-demultiplexed-seqs jioned_paired_filtered.qza --p-trim-length 150 --o-representative-sequences rep-seqs.qza --o-table table.qza --p-sample-stats --o-stats deblur-stats.qza
## view your .qzv files 
qiime tools view demux.qzv

# Download classifier that has been pretrained on GreenGenes database with 99% OTUs identity 
wget -O "gg-13-8-99-515-806-nb-classifier.qza" "https://data.qiime2.org/2018.2/common/gg-13-8-99-515-806-nb-classifier.qza"

#getting feature biom file
qiime tools export table.qza --output-dir ./

# convert it to tsv and view it
biom convert -i feature-table.biom -o feature-table.tsv --to-tsv
biom head -i feature-table.tsv # reduced view of the data 
head feature-table.tsv

# assign taxonomy to your sequences
qiime feature-classifier classify-sklearn --i-classifier gg-13-8-99-515-806-nb-classifier.qza --i-reads rep-seqs.qza --o-classification taxonomy.qza

#getting taxonomy biom file 
qiime tools export taxonomy.qza --output-dir ./ # the output is a tsv
