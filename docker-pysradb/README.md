# docker-pysradb

This repo contains the docker files for image stored in `karolinabojkowska/docker-pysradb`.

## Table of contents
* [Building docker image](#Building-docker-image)
* [Metadata retrieval script for a single accession_number](#Metadata-retrieval-script-for-a-single-accession_number)
* [Metadata retrieval script for a query](#Metadata-retrieval-script-for-a-query)
* [Running container](#Running-container)
* [Usage examples](#Usage-examples)

## Building docker image

The source files can be found in the github repo : https://github.com/karolinabojkowska/docker-pysradb

You must clone the git repository first and navigate to it. 

You need docker daemon to rebuild the docker image. See https://docs.docker.com/engine/.
```
docker build -t docker-pysradb . # --network=host
```
You can skip this if you want to use an already built image on docker hub (image name `karolinabojkowska/docker-pysradb:v1`). 

## Metadata retrieval script for a single accession_number

Python script that retrieves detailed metadata for a given sra_id is under the `scripts` directory and is called `get_sra_metadata.py`.

Usage :
```
get_sra_metadata.py <sra_id> <out_file>
# input sra id : an input string with SRA accession ID
# outfile : output file (This should be in a a mounted host directory, so that the output file is visible from the host)
```
## Metadata retrieval script for a query

Python script that retrieves the metadata for a specific query is under the `scripts` directory and is called `search_sra_db.py`.

Usage :
```
search_sra_db.py <"query"> <out_file>
# input query : "a space separated list of key words"
# outfile : output file (This should be in a a mounted host directory, so that the output file is visible from the host)

```
## Running container
```
# pull it from remote repo 
docker pull karolinabojkowska/docker-pysradb:v1

# example specific run command
docker run karolinabojkowska/docker-pysradb:v1 python get_sra_metadata.py sra_id output.tab

# you will need -v option to mount data file/folder if they are used as arguments. With the -u option you add user permissions.
docker run -v /mydata/path/:/home/dockeruser/data/:rw -u "$(id -u):$(id -g)" karolinabojkowska/docker-pysradb:v1 python get_sra_metadata.py sra_id /home/dockeruser/data/file1.tab
```
## Usage examples

### Usage example for SRP265425 data set for an output file located in /home/karo/Documents/
```
docker run -it --rm --network=host -u "$(id -u):$(id -g)"  -v /home/karo/Documents/:/home/dockeruser/data/:rw docker-pysradb python get_sra_metadata.py SRP265425 /home/dockeruser/data/SRP265425.metadata.tab
```
### Usage example for "mouse liver Chip-seq embryo Illumina" query for an output file /home/karo/Documents/myQuery.metadata.tab
```
docker run -it --rm --network=host -u "$(id -u):$(id -g)" -v /home/karo/Documents/:/home/dockeruser/data/:rw docker-pysradb python search_sra_db.py "mouse liver Chip-seq embryo Illumina" /home/dockeruser/data/myQuery.metadata.tab
```


