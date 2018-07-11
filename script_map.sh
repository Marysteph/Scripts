#!/bin/bash

module load bwa

# bwa mem -t 10 -R '@RG\tID:Unknwn\tPL:Illumina\tLB:library\tSM:' -M ../Map/Zea_mays.AGPv4.dna.toplevel.fa ../SRR3134441_1_paired.fastq ../SRR3134441_1_reverse_paired.fastq > SRR3134441_trim.sam

# bwa mem -t 10 -R '@RG\tID:Unknwn\tPL:Illumina\tLB:library\tSM:' -M ../Map/Zea_mays.AGPv4.dna.toplevel.fa ../SRR3134467_1_paired.fastq ../SRR3134467_1_reverse_paired.fastq > SRR3134467_trim.sam

# bwa mem -t 10 -R '@RG\tID:Unknwn\tPL:Illumina\tLB:library\tSM:' -M ../Map/Zea_mays.AGPv4.dna.toplevel.fa ../SRR3134468_1_paired.fastq ../SRR3134468_1_reverse_paired.fastq > SRR3134468_trim.sam

bwa mem -t 10 -R '@RG\tID:Unknwn\tPL:Illumina\tLB:library\tSM:' -M ../Map/Zea_mays.AGPv4.dna.toplevel.fa ../SRR3134441_1.fastq.gz ../SRR3134441_2.fastq.gz > SRR3134441_untrim.sam

bwa mem -t 10 -R '@RG\tID:Unknwn\tPL:Illumina\tLB:library\tSM:' -M ../Map/Zea_mays.AGPv4.dna.toplevel.fa ../SRR3134468_1.fastq.gz ../SRR3134468_2.fastq.gz > SRR3134468_untrim.sam

bwa mem -t 10 -R '@RG\tID:Unknwn\tPL:Illumina\tLB:library\tSM:' -M ../Map/Zea_mays.AGPv4.dna.toplevel.fa ../SRR3134467_1.fastq.gz ../SRR3134467_2.fastq.gz > SRR3134467_untrim.sam

