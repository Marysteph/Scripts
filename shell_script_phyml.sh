#!/bin/bash
# this script will loop through the user trees (topologies produced by ape)
# and launch a PhyML job for each of them, without allowing PhyML to modify the
# topology.
# We will collect the following values:
# - ML tree length (sum of branch lengths)
# - parsimony score achieved on that same ML tree
# - ML tree likelihood

PHYML=`which phyml`
INPUTSEQS="mito_sequences_aligned_mafft_auto.phy"
OUTPUTSTATS=${INPUTSEQS}_phyml_stats.txt
OUTPUTTREE=${INPUTSEQS}_phyml_tree.txt
TREEFILE="hundred_trees.nh"
TEMPTREEFILE="/tmp/inputtree.nh" # will be created in the current working directory
COMBINEDRESULTS="all_results_JC69.txt"

# the number of lines in our tree file is the number of trees
# ntrees=`wc -l < $TREEFILE` 
# or, equivalently:
ntrees=$( wc -l < $TREEFILE ) 
echo "Analyzing $ntrees trees..."

# writing a header line:
echo -e "logLk\tparsimony\ttree_size" > $COMBINEDRESULTS  # -e to take into account the special characters in the string
# now the loop on all these trees:
for i in $( seq 1 $ntrees ) 
do
	echo Tree ${i}...
	# we will store our input file in the file $TEMPTREEFILE
	sed -n ${i}p $TREEFILE > $TEMPTREEFILE
	# now we can launch phyml
	$PHYML -u $TEMPTREEFILE -m JC69 -c 5 -a e -t e -f e -v e -o lr -b 0 -i $INPUTSEQS > /dev/null 
	egrep '^. (Log-likelihood|Parsimony|Tree size):' $OUTPUTSTATS | awk 'NR == 1 { buf = $NF; next } { buf = buf "\t" $NF } END { print buf }' >> $COMBINEDRESULTS
done

