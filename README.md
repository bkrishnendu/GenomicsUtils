# GenomicsUtils
Parse Fastq files and and retrieve the second and fourth line
from parseFastQ import readFastq

seqs, quals = readFastq('SRR835775_1.first1000.fastq')

print(seqs[:20])

print(quals[:20])

