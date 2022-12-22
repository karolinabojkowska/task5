#!/bin/python3
#!/usr/bin/env python3

#############################################################################
### Author: Karolina Bojkowska (karolina.bojkowska@gmail.com)
### Date: 17/12/2022
###
### This script retrieves metadata from SRA repository for a given query string 
### and saves it to a tab-separated file.
###
### Uses two arguments:
### query = "space-separated key words" 
### out = full path to the out file
#############################################################################

#############################################################################
# Import modules I
#############################################################################

import argparse
from argparse import RawTextHelpFormatter
from pysradb.sraweb import SRAweb
import pandas
import os

#############################################################################
# Load the arguments passed to the python script
#############################################################################

parser=argparse.ArgumentParser(
    description='''
***********************************************************************************************************
*** This script retrieves metadata from a SRA repository for a query and saves it to a tab-separated file. 
*** Usage : python search_sra.py "query keywords string" output.tab
*** Usage example: python get_sra_metadata.py "liver human single cell rna-seq" /your/fav/path/myquery.tab 
*** Uses pysradb. For more details see https://saket-choudhary.me/pysradb
***********************************************************************************************************''',formatter_class=RawTextHelpFormatter)

parser.add_argument('query', type = str)
parser.add_argument('out_file',type = str)
args=parser.parse_args()

#print(args)

query = ''.join(args.query)
out_file = ''.join(args.out_file)

#############################################################################
# Download metadata for the sra query and write to TAB-file    
#############################################################################

db = SRAweb()

# get metadata 
df = db.search_sra(query) 

#print(df )

# drop columns with NaN or No value
#df2 = df.dropna(axis = 1, how = 'all')

if df is not None:
    print("\n[INFO] Metadata retrieval for query '", query, "' completed.", sep ="")
else:
    print("\n[WARNING] Metadata retrieval for query '", query ,"' gave no results. Consider using more general terms.", sep="")
    quit()



# write metadata to file
with open(out_file, 'w') as f:
    df.to_csv(f, sep = '\t', index = False)

if os.path.exists(out_file) and os.path.getsize(out_file) > 0:
    print("\n[INFO] Metadata for query '", query, "' written to file ", out_file,".", sep ="")
