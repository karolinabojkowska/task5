FROM r-base:latest

MAINTAINER Karolina Bojkowska (karolina.bojkowska@gmail.com)

# install required packages 

LABEL org.label-schema.license="GPL-2.0" \
      org.label-schema.vcs-url="https://github.com/rocker-org/rocker" \
      maintainer="Dirk Eddelbuettel <edd@debian.org>"

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
                ghostscript \
                lmodern \
                qpdf \
                r-cran-formatr \
                r-cran-ggplot2 \
                r-cran-knitr \
		r-cran-rmarkdown \
                r-cran-runit \
                r-cran-testthat \
                texinfo \
                texlive-fonts-extra \
                texlive-fonts-recommended \
                texlive-latex-extra \
                texlive-latex-recommended \
                texlive-luatex \
                texlive-plain-generic \
                texlive-science \
                texlive-xetex \
        && install.r binb linl pinp tint dplyr\
        && mkdir ~/.R \
        && echo _R_CHECK_FORCE_SUGGESTS_=FALSE > ~/.R/check.Renviron \
        && cd /usr/local/bin \
        && ln -s /usr/lib/R/site-library/littler/examples/render.r .

# take care of user permissions
ARG UNAME=dockeruser
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME -d /home/$UNAME
USER $UNAME

# make dirs
RUN mkdir -p /home/$UNAME/data
RUN mkdir -p /home/$UNAME/code
COPY scripts/ /home/$UNAME/code/

# default command
CMD Rscript -e "rmarkdown::render('/home/dockeruser/code/makeMetadataReport.Rmd', output_format='pdf_document', output_file='/home/dockeruser/data/out.pdf')" 

