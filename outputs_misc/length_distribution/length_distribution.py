import sys
import os

sample_files_path = sys.argv[1]

sample_files = os.listdir(sample_files_path)
sample_files = list(map(lambda x: sample_files_path+x, sample_files))
sample_files = list(filter(lambda x: x.split(".")[-1]=='bl', sample_files))

def find_reads(sample_files,*rnatype):
    hits_length = {}
    #sample_files= filter(lambda x: x.split(".")[-1]=='oll',sample_files)
    for length_i in sample_files:
        hits = list(open(length_i))
        length = int(length_i.split(".")[-2])
        hits = hits[:-1]
        if not rnatype:
            hit = map(lambda x: x.split("\t")[0],map(lambda x: x.replace("\n",""),hits))
            hit_count = sum(map(lambda x: int(x.split("_")[1]),hit))
            hits_length[length] = hit_count
        elif rnatype[0] =='rRNA':
            hit = map(lambda x: x.split("\t")[0],
                      filter(lambda x: x.split("\t")[-2]==rnatype[0],
                             map(lambda x: x.replace("\n",""),hits)))
            hit_count = sum(map(lambda x: int(x.split("_")[1]),hit))
            #hits_length.append(hit_count)
            hits_length[length] = hit_count
        else:
            hit = map(lambda x: x.split("\t")[0],
                      filter(lambda x: x.split("\t")[-1]==rnatype[0],
                             map(lambda x: x.replace("\n",""),hits)))
            hit_count = sum(map(lambda x: int(x.split("_")[1]),hit))
            #hits_length.append(hit_count)
            hits_length[length] = hit_count
    return hits_length

def find_hits(sample_files,*rnatype):
    hits_length = {}
    #sample_files= filter(lambda x: x.split(".")[-1]=='oll',sample_files)
    for length_i in sample_files:
        hits = list(open(length_i))
        length = int(length_i.split(".")[-2])
        hits = hits[:-1]
        if not rnatype:
            hit = map(lambda x: x.split("\t")[0],map(lambda x: x.replace("\n",""),hits))
#             hits_length.append(len(list(hit)))
            hits_length[length] = len(list(hit))
        elif rnatype[0] =='rRNA':
            hit = map(lambda x: x.split("\t")[0],
                      filter(lambda x: x.split("\t")[-2]==rnatype[0],
                             map(lambda x: x.replace("\n",""),hits)))
#             hits_length.append(len(list(hit)))
            hits_length[length] = len(list(hit))
        else:
            hit = map(lambda x: x.split("\t")[0],
                      filter(lambda x: x.split("\t")[-1]==rnatype[0],
                             map(lambda x: x.replace("\n",""),hits)))
#             hits_length.append(len(list(hit)))
            hits_length[length] = len(list(hit))

    return hits_length

all_hits = find_hits(sample_files)
rrna_hits = find_hits(sample_files, 'rRNA')
potential_hits = {}
for length in all_hits:
    potential_hits[length] = all_hits[length]-rrna_hits[length]

print('''all_hits=''')
print(all_hits)
print('all_hits = collections.OrderedDict(sorted(all_hits.items()))')

print('''rRNA_hits=''')
print(rrna_hits)
print('rRNA_hits = collections.OrderedDict(sorted(rRNA_hits.items()))')

print('''potential_hits=''')
print(potential_hits)
print('potential_hits = collections.OrderedDict(sorted(potential_hits.items()))')
