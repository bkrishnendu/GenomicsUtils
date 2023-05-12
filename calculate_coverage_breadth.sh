#!/bin/bash

usage() {
  echo "Usage: $(basename $0) -r REF_GENOME_FILE -s WGS_SAMPLE [-h] [-f FORMAT]"
  echo ""
  echo "Options:"
  echo "  -r  Reference genome file in FASTA format"
  echo "  -s  Short read sample file in FASTQ format"
  echo "  -h  Show help"
  echo "  -f  Output format: 'table' (default) or 'csv'"
  echo ""
}

# default values
FORMAT="table"
MIN_COVERAGE_DEPTH_START=5
MIN_COVERAGE_DEPTH_END=100
MIN_COVERAGE_DEPTH_INCREMENT=5

# parse command-line arguments
while getopts ":r:s:f:h" opt; do
  case ${opt} in
    r ) REF_GENOME_FILE=$OPTARG;;
    s ) WGS_SAMPLE=$OPTARG;;
    f ) FORMAT=$OPTARG;;
    h ) usage
        exit;;
    \?) echo "Invalid option: -$OPTARG" >&2
        usage
        exit 1;;
    :) echo "Option -$OPTARG requires an argument" >&2
        usage
        exit 1;;
  esac
done
shift $((OPTIND -1))

# validate required options
if [[ -z "$REF_GENOME_FILE" || -z "$WGS_SAMPLE" ]]; then
  echo "Error: -r and -s options are required"
  usage
  exit 1
fi

# get length of reference genome
REF_GENOME_LENGTH=$(bowtie2-inspect -s $REF_GENOME_FILE | awk '{ FS = "\t" } ; BEGIN{L=0}; {L=L+$3}; END{print L}')

# print table header
if [ "$FORMAT" == "table" ]; then
  echo -e "MIN_COVERAGE_DEPTH\tBASES_COVERED\tGENOME_COVERAGE"
fi

# iterate over MIN_COVERAGE_DEPTH values
for MIN_COVERAGE_DEPTH in $(seq $MIN_COVERAGE_DEPTH_START $MIN_COVERAGE_DEPTH_INCREMENT $MIN_COVERAGE_DEPTH_END); do

  # get total number of bases covered at MIN_COVERAGE_DEPTH or higher
  BASES_COVERED=$(samtools mpileup -B -Q 0 -d 1000000 -f $REF_GENOME_FILE $WGS_SAMPLE | awk -v X=$MIN_COVERAGE_DEPTH '$4>=X' | wc -l)

  # calculate genome coverage
  GENOME_COVERAGE=$(echo "scale=2; $BASES_COVERED / $REF_GENOME_LENGTH" | bc)

  # print results in specified format
  if [ "$FORMAT" == "table" ]; then
    echo -e "$MIN_COVERAGE_DEPTH\t$BASES_COVERED\t$GENOME_COVERAGE"
  elif [ "$FORMAT" == "csv" ]; then
    echo "$MIN_COVERAGE_DEPTH,$BASES_COVERED,$GENOME_COVERAGE"
  else
    echo "Error: invalid format specified"
    usage
    exit 1
  fi

done

