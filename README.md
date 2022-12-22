# task5

This repo contains the solution for task5

## Table of contents
* [Metadata report pipeline](#Metadata-report-pipeline)
* [Usage example for "mouse liver Chip-seq embryo Illumina" query for an output directory /home/karo/Documents/report and format pdf](#Usage-example-for-"mouse-liver-Chip-seq-embryo-Illumina"-query-for-an-output-directory-/home/karo/Documents/report-and-format-pdf)
* [Building docker images](#Building-docker-images)


## Metadata report pipeline

Bash script that makes metadata report for a given query is under the `pipelines` directory and is called `sra_metadata_report.sh`.

Usage :
```
sra_query_report.sh <"query string"> <output_dir_absolute_path> <metics_file_format> ( pdf or html )
# query string : "a space separated list of key words"
# output_dir_absolute_path : absolute path to the working directory
# metrics_file_format : format of the output file : pdf or html
```
## Usage example for "mouse liver Chip-seq embryo Illumina" query for an output directory /home/karo/Documents/report and format pdf
```
/path/to/sra_query_report.sh "mouse liver Chip-seq embryo Illumina" /home/karo/Documents/report pdf
```
## Building docker images

If for some reason you want to modify and build the images yourself, the source files for docker containers can be found in the directories :

- docker-pysradb

- docker-plotmetadata

You must clone the current repository first and navigate to the repo for which you want to build the image.

You need docker daemon to rebuild the docker image. See https://docs.docker.com/engine/.

```
cd docker-pysradb

docker build -t docker-pysradb . # --network=host

cd docker-plotmetadata

docker build -t docker-plotmetadata . # --network=host

```


