module load trimmomatic
trimmomatic PE -threads 10 -phred33 SRR3134441_1.fastq.gz SRR3134441_2.fastq.gz SRR3134441_1_paired.fastq SRR3134441_1_forward_unpaired.fastq SRR3134441_1_reverse_paired.fastq SRR3134441_1_reverse_unpaired.fq.gz ILLUMINACLIP:/export/apps/trimmomatic/0.38/adapters/TruSeq3-PE.fa:2:28:7 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:28 MINLEN:100

trimmomatic PE -threads 10 -phred33 SRR3134467_1.fastq.gz SRR3134467_2.fastq.gz SRR3134467_1_paired.fastq SRR3134467_1_forward_unpaired.fastq SRR3134467_1_reverse_paired.fastq SRR3134467_1_reverse_unpaired.fq.gz ILLUMINACLIP:/export/apps/trimmomatic/0.38/adapters/TruSeq3-PE.fa:2:28:7 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:28 MINLEN:100

trimmomatic PE -threads 10 -phred33 SRR3134468_1.fastq.gz SRR3134468_2.fastq.gz SRR3134468_1_paired.fastq SRR3134468_1_forward_unpaired.fastq SRR3134468_1_reverse_paired.fastq SRR3134468_1_reverse_unpaired.fq.gz ILLUMINACLIP:/export/apps/trimmomatic/0.38/adapters/TruSeq3-PE.fa:2:28:7  LEADING:3 TRAILING:3 SLIDINGWINDOW:4:28 MINLEN:100

