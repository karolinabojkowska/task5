# task5

This repository contains my proposed solution for task5

## Table of contents
* [Metadata report pipeline](#Metadata-report-pipeline)
* [Usage example for "mouse liver Chip-seq embryo Illumina" query for an output directory /home/karo/Documents/report and format pdf](#Usage-example-for-"mouse-liver-Chip-seq-embryo-Illumina"-query-for-an-output-directory-/home/karo/Documents/report-and-format-pdf)
* [Building docker images](#Building-docker-images)
* [Possible improvments](#Possible-improvments)


## Metadata report pipeline

I made a report pipeline that takes advantage of two docker images for 
    1. retrieving metadata from the SRA database for a specific query (docker-pysradb) and saving it to TAB-separated file
    2. making a pdf / html report with selected metrics from the TAB-separated file 

Bash script that makes metadata report for a given query is under the `pipelines` directory and is called `sra_metadata_report.sh`.

To use it you must first clone the current repository. 

You need docker daemon for the pipeline to work. See https://docs.docker.com/engine/ for downloading docker.

`sra_metadata_report.sh` usage :
```
bash sra_query_report.sh <"query string"> <output_dir_absolute_path> <metics_file_format> ( pdf or html )
```
The script takes three arguments:
- query string : "a space separated list of key words"
- output_dir_absolute_path : absolute path to the working directory where the results will be output
- metrics_file_format : format of the output file - pdf or html

#### Usage example for "mouse liver Chip-seq embryo Illumina" query for an output directory /home/karo/Documents/report and format pdf
```
bash /path/to/sra_query_report.sh "mouse liver Chip-seq embryo Illumina" /home/karo/Documents/report pdf
```
## Building docker images

If you want to modify and build the images yourself, the source files for docker containers can be found in the directories :

- docker-pysradb

- docker-plotmetadata

You must clone the current repository first and navigate to the repo for which you want to build the image.

To build the docker image:
```
cd docker-pysradb

docker build -t docker-pysradb . # --network=host

cd docker-plotmetadata

docker build -t docker-plotmetadata . # --network=host

docker image ls
```
Additional information about the docker images and their functioning are in the README.md files in the docker directories.

## Possible improvments

There are many possible changes and developments to my proposed solution. 

It would be useful to have an additional way to retrieve detailed metadata for pre-selected studies. This would also allow accessing the http paths to fastq files. One could imagine subsetting the metrics table with a user-specified `config.txt` file with the values for specific metrics in the following format: 
```
$ cat config.txt
organism_name=Mus musculus
instrument=Illumina Hiseq 2500,Illumina Novaseq 6000
library_strategy=cDNA,RT-PCR
```
We could then use the (adapted) python script `docker-pysradb/scripts/get_sra_metadata.py` to retrieve detailed metadata for specific library accession numbers and maybe plot some additional metadata to get further insight into the study metadata.

Said that, I believe that the best would be to make a web application that uses (some of) the docker containers I created. One could enter the query words and the app would retrieve the table with metadata. It could also propose (dynamic) graphs for given metrics from a drop-down menu that would facilitate library selection. 

