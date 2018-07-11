#!/bin/bash

module load samtools

for fi in map_out/*.sam ;
do echo "processing ${fi}" ;
samtools view -u -@ 10 -T Map/Zea_mays.AGPv4.dna.toplevel.fa ${fi} | samtools sort -@ 10 -o ${fi:8:13}all.bam ;

done

