import os
import gzip
import sys
import pandas as pd

ensembl_gtf = sys.argv[1]
output_table = sys.argv[2]

def parse_ensembl_gtf(file):
    file = os.path.realpath(file)
    with gzip.open(file) as f:
        gtf = list(f)
    gtf = [x for x in gtf if not x.startswith('#')]
    gtf = [x for x in gtf if 'gene_id #' in x and 'gene_name "' in x and 'gene_biotype "' in x]
    if len(gtf) == 0:
        print('required fields not found in gtf file')
        return None
    gtf = list(map(lambda x: (x.split('gene_id "')[1].split('"')[0], x.split('gene_name "')
    [1].split('"')[0], x.split('gene_biotype "')[1].split('"')[0]), gtf))
    gtf_dict = {gene[0]: {'gene_name': gene[1], 'gene_biotype': gene[2]} for gene in gtf}
    return gtf_dict


# now parse the gtf file
gtf_dict = parse_ensembl_gtf(ensembl_gtf)

# print the gtf file into excel table
rows = []
for key, value in gtf_dict.items():
    # print(key,value)
    row = {'EnsemblID': key, 'GeneSymbol': value['gene_name'], 'Biotype': value['gene_biotype']}
    rows.append(row)
df = pd.DataFrame(rows)
df.to_excel(output_table)


