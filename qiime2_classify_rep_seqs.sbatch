#!/usr/bin/env bash
#SBATCH -p highmem
#SBATCH -w mammoth
#SBATCH -J qiime2_jb
#SBATCH -n 4

# load the qiime2 module
module load qiime2/2018.6

READSDIR=/home/blyimo/Bushmeat_analysis/new_caporaso_data
WKDIR=/var/scratch/jb_beatus # this is on mammoth
#METADATA=${WKDIR}/batch2-sample-metadata.tsv
METADATA=${WKDIR}/dummy_metadata.tsv
CLASSIFIER=${WKDIR}/Feature_classifiers/gg-13-8-99-515-806-nb-classifier.qza

cd ${WKDIR}

#We run the rep seqs through the classifier with:
#qiime feature-classifier classify-sklearn \
#  --i-classifier $CLASSIFIER \
#  --i-reads rep-seqs.qza \
#  --o-classification taxonomy.qza

# then we build the visualization:
# qiime metadata tabulate \
#  --m-input-file taxonomy.qza \
#  --o-visualization taxonomy.qzv


qiime taxa barplot \
  --i-table table.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file ${METADATA} \
  --o-visualization taxa-bar-plots.qzv
