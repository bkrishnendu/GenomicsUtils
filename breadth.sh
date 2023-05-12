#!/bin/bash

# set variables
REF_GENOME_FILE=my_ref_genome.fasta
BAM_SAMPLE=my_short_read_sample.bam

# define range of MIN_COVERAGE_DEPTH values to iterate over
MIN_COVERAGE_DEPTH_START=5
MIN_COVERAGE_DEPTH_END=100
MIN_COVERAGE_DEPTH_INCREMENT=5

# get length of reference genome
REF_GENOME_LENGTH=$(bowtie2-inspect -s $REF_GENOME_FILE | awk '{ FS = "\t" } ; BEGIN{L=0}; {L=L+$3}; END{print L}')

# print table header
echo -e "MIN_COVERAGE_DEPTH\tBASES_COVERED\tGENOME_COVERAGE"

# iterate over MIN_COVERAGE_DEPTH values
for MIN_COVERAGE_DEPTH in $(seq $MIN_COVERAGE_DEPTH_START $MIN_COVERAGE_DEPTH_INCREMENT $MIN_COVERAGE_DEPTH_END); do

  # get total number of bases covered at MIN_COVERAGE_DEPTH or higher
  BASES_COVERED=$(samtools mpileup $BAM_SAMPLE | awk -v X=$MIN_COVERAGE_DEPTH '$4>=X' | wc -l)

  # calculate genome coverage
  GENOME_COVERAGE=$(echo "scale=2; $BASES_COVERED / $REF_GENOME_LENGTH" | bc)

  # print results in tabular format
  echo -e "$MIN_COVERAGE_DEPTH\t$BASES_COVERED\t$GENOME_COVERAGE"

done
