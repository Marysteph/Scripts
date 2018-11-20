#!/usr/bin/env bash
#SBATCH -p highmem
#SBATCH -w mammoth
#SBATCH -J qiime2_jb
#SBATCH -n 4

# load the qiime2 module
module load qiime2/2018.6

READSDIR=/home/blyimo/Bushmeat_analysis/new_caporaso_data
WKDIR=/var/scratch/jb_beatus # this is on mammoth
METADATA=${WKDIR}/batch2-sample-metadata.tsv


# WARNING! The reads directory must contain *only* the R1 and R2 files in fastq.gz format.
# In case the reads are already decompressed and one doesn't want to compress, it is necessary to build a manifest file

# PREPARING THE MANIFEST FILE
cd ${READSDIR}
echo "sample-id,absolute-filepath,direction" > ${WKDIR}/manifest.csv # overwrites in case the file exists
for filename in *_R[12]_001.fastq
do
  sample=${filename%%_*} # retains only what is before the first underscore char
  tmp=${filename##*_R} # tmp starts with "1" or "2", depending on the direction of the read
  if [ "${tmp:0:1}" = "1" ]; then direction="forward"; else direction="reverse"; fi
  echo "sample_${sample},${READSDIR}/${filename},${direction}" >> ${WKDIR}/manifest.csv
done


cd $WKDIR # so no need to specify full path

# first step: import data from .fastq files into a Qiime2 .qza file:
qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --source-format PairedEndFastqManifestPhred33 --input-path manifest.csv --output-path demux_paired_end_reads.qza


# to create the visualization for the reads and overall base calling quality:
qiime demux summarize --i-data demux_paired_end_reads.qza --o-visualization demux_paired_end_reads.qzv

# we visualize the qzv after moving it onto my public_html space and then uploading it to https://view.qiime2.org
 


# using the DADA2 thing in order to denoise the data and create the feature table
# from the visualization of the stats from the qiime demux summarize command, we decide to cut the forward
# reads at length 105 and reverse reads at length 95. 
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs demux_paired_end_reads.qza \
  --p-n-threads 4 \
  --p-trim-left-f 5 \
  --p-trim-left-r 5 \
  --p-trunc-len-f 150 \
  --p-trunc-len-r 150 \
  --o-table table.qza \
  --o-representative-sequences rep-seqs.qza \
  --o-denoising-stats denoising-stats.qza


# building visualizations:
qiime metadata tabulate \
 --m-input-file denoising-stats.qza \
 --o-visualization denoising-stats.qzv

qiime feature-table summarize --i-table table.qza --o-visualization table.qzv

# then build the visualisation for the representative sequences:
qiime feature-table tabulate-seqs --i-data rep-seqs.qza --o-visualization rep-seqs.qzv


# then we build a phylogenetic tree:

# the following all-in-one is available in 2018.11, not in 2018.6
# qiime phylogeny align-to-tree-mafft-fasttree \
#  --i-sequences rep-seqs.qza \
#  --o-alignment aligned-rep-seqs.qza \
#  --o-masked-alignment masked-aligned-rep-seqs.qza \
#  --o-tree unrooted-tree.qza \
#  --o-rooted-tree rooted-tree.qza

qiime alignment mafft \
  --i-sequences rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza

qiime tools view --i-alignment aligned-rep-seqs.qza --o-visualization aligned_rep_seqs.qzv

qiime alignment mask \
  --i-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza

qiime phylogeny fasttree \
  --i-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza

