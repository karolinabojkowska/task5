#!/bin/python3
#!/usr/bin/env python3

#############################################################################
### Author: Karolina Bojkowska (karolina.bojkowska@gmail.com)
### Date: 17/12/2022
###
### This script retrieves detailed metadatf from SRA repository and saves 
### it to a tab-separated file.
###
### Uses two arguments:
### sra = SRA access ID
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
*** This script retrieves detailed metadata for a given accession_number from a SRA repository 
*** and saves it to a tab-separated file. 
*** Usage : python get_sra_metadata.py sra_ID output.tab
*** Usage example: python get_sra_metadata.py SRP265425 /your/favourite/path/SRP265425.tab 
*** Uses pysradb. For more details see https://saket-choudhary.me/pysradb.
***********************************************************************************************************''',
    formatter_class=RawTextHelpFormatter)

parser.add_argument('sra', type = str)
parser.add_argument('out_file',type = str)
args=parser.parse_args()

#print(args)

sra = ''.join(args.sra)
out_file = ''.join(args.out_file)

#############################################################################
# Download metadata for the sra_accession_number and write to TAB-file    
#############################################################################

db = SRAweb()

# get metadata 
df = db.sra_metadata(sra , detailed = True) 

# drop columns with NaN or No value
#df2 = df.dropna(axis = 1, how = 'all')

if df is not None:
    print("\n[INFO] Metadata retrieval for ", sra, " completed.", sep ="")
else:
    print("\n[WARNING] Metadata retrieval for ",sra," failed. Please check your sra_accession_number.", sep="")
    quit()

# write metadata to file
with open(out_file, 'w') as f:
    df.to_csv(f, sep = '\t', index = False)

if os.path.exists(out_file) and os.path.getsize(out_file) > 0:
    print("\n[INFO] Metadata for ", sra, " written to file ", out_file,".", sep ="")
