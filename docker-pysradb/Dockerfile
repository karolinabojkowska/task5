FROM python:3

MAINTAINER Karolina Bojkowska (karolina.bojkowska@gmail.com)

# install required packages from requirements.txt

WORKDIR /usr/src/app

COPY requirements.txt ./

# ignore a warning that pip works as a root
ENV PIP_ROOT_USER_ACTION=ignore

RUN pip install --no-cache-dir -r requirements.txt

# copy python scripts and change permissions
COPY scripts/ . 
RUN chmod +x get_sra_metadata.py
RUN chmod +x search_sra_db.py

#  take care of user permissions
ARG UNAME=dockeruser
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME -d /home/$UNAME
USER $UNAME

# make dirs
RUN mkdir -p /home/$UNAME/data

# default command
CMD [ "python", "script.py" ]

