"""Read the fastq file and retrive the second and fourth line"""
def readFastq(fastq):
    """Reads FASTQ file and remove the special characters!"""
    sequences = []
    qualities = []
    with open(fastq) as fq:
        while True:
            fq.readline()  # skip name line
            seq = fq.readline().rstrip()  # read base sequence
            fq.readline()  # skip placeholder line
            qual = fq.readline().rstrip()  # base quality line
            if len(seq) == 0: # check if the code has reached the end of the file
                break
            sequences.append(seq)
            qualities.append(qual)
    return sequences, qualities








