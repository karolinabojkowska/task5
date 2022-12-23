# docker-plotmetadata

This repo contains the source files for a docker image stored in `karolinabojkowska/docker-plotmetadata`.

## Table of contents
* [Building docker image](#Building-docker-image)
* [Metadata summary](#Metadata-summary)
* [Running container](#Running-container)
* [Usage example](#Usage-example)

## Building docker image

The source files can be found in the github repo : https://github.com/karolinabojkowska/docker-plotmetadata 

You must clone the git repository first and navigate to it. 

You need docker daemon to rebuild the docker image. See https://docs.docker.com/engine/.
```
docker build -t docker-plotmetadata . # --network=host

docker image ls 

```
You can skip this if you want to use an already built image `karolinabojkowska/docker-plotmetadata:v1`. 

## Metadata summary 

R markdown that creates a metrics summary for a given query search with a TAB-delimited SRA metadata file as input.

Usage :
```
Rscript -e "rmarkdown::render('/home/dockeruser/code/makeMetadataReport.Rmd', output_format='html_document', output_file = '/home/dockeruser/data/MetadataReport.html')" <"query"> <in_file>
# query : "a space separated list of key words"
# in_file : input file (This should be in a a mounted host directory, so that the output file is visible from the host)

```
## Running container
```
# you will need -v option to mount data folder with yout input file. The outpt file will be created in the same directory. With the -u option you msut add user permissions.

## use output_format='pdf_document' for output file in PDF format
docker run -it --rm -u "$(id -u):$(id -g)" -v /path_to_wd/:/home/dockeruser/data/:rw docker-plotmetadata Rscript -e "rmarkdown::render('/home/dockeruser/code/makeMetadataReport.Rmd', output_format='pdf_document', output_file = '/home/dockeruser/data/MetadataReport.pdf')" "query" /home/dockeruser/data/mySRAqueryOut.tab

## use output_format='html_document' for output file in HTML format
docker run -it --rm -u "$(id -u):$(id -g)" -v /path_to_wd/:/home/dockeruser/data/:rw docker-plotmetadata Rscript -e "rmarkdown::render('/home/dockeruser/code/makeMetadataReport.Rmd', output_format='html_document', output_file = '/home/dockeruser/data/MetadataReport.html')" "query" /home/dockeruser/data/mySRAqueryOut.tab

```
## Usage example for "mouse embryo chip-seq illumina" with SRA metadata in file /home/karo/Documents/mySRA.tab
```
docker run -it -u "$(id -u):$(id -g)" --rm --network=host -v /home/karo/Documents/:/home/dockeruser/data/:rw docker-plotmetadata Rscript -e "rmarkdown::render('/home/dockeruser/code/makeMetadataReport.Rmd', output_format='pdf_document', output_file = '/home/dockeruser/data/MetadataReport.pdf')" "mouse embryo chip-seq illumina" /home/dockeruser/data/mySRA.tab
```


