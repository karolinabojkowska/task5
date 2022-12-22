#!/bin/bash

# December 2022 : version 1.0 
# Karolina Bojkowska (karolina.bojkowska@gmail.com)

########################################################################
# Pipeline Usage:
# The script should be run using the following command:
# bash $SCRIPT_PATH/sra_query_report.sh <"QUERY"> <OUTPUT_FOLDER> <format>
##########################################################################

# exit setup
trap "exit 1" TERM
TOP_PID=$$

##########################################################################
# FUNCTIONS
##########################################################################

function infomsg {
        local log_file=$1
        shift
        local msg="${@}"
        local date=`date`

        echo -e "[$date][INFO] $msg" >&2

        if [ -s "$log_file" ] && [ "$log_file" != "0" ]; then
                echo -e "[$date][INFO] $msg" >> $log_file
        fi
}

function exitmsg {
        local log_file=$1
        shift
        local msg="$@"
        local date=`date`
        if [ "$log_file" != "0" ] && [ -s "$log_file" ]; then
                echo -e "[$date][FATAL] $msg" >> $log_file
        fi
        echo -e "[$date][FATAL] $msg" >&2
        kill -s TERM $TOP_PID
}

function checkinstalledtool {
        local tool=$1
        local log_file=$2

        local toolloc=$(command -v $tool)

        if [ -z "$toolloc" ]; then
                exitmsg $log_file "$tool TOOL is not installed"
        else
                infomsg $log_file "$tool PATH: $toolloc"
        fi
}

function checkdockerimage {
        local tool=$1
        
	dim=$(docker image ls | grep $tool)
	echo dim
}

function checkdockerimagepull {
	local tool=$1
        local log_file=$2
	
	local toolloc=$(docker image ls | grep $tool)

	if [ -z "$toolloc"  ] ; then 
		exitmsg $log_file "$tool IAMGE is not available"
        else
                infomsg $log_file "$tool IMAGE $toolloc"
        fi
}

function executecmd {
        local command_line=$1
        local log_file=$2
        local send2bg=$3

        if [ ! -s $log_file ]; then
                log_file=0
        fi

        infomsg $log_file "CMD: $command_line"

        # option to run on background
        if [ ! -z "$send2bg" ] && [ $send2bg == "bg" ]; then
                eval "$command_line" &
                infomsg $log_file "CMD: Sent to background execution"
        else
                tstart=$(date +%s)
                eval "$command_line"
                tend=$(date +%s)
                infomsg $log_file "CMD: Executed"
                infomsg $log_file "Elapsed time: "$(($tend-$tstart))"s."
        fi
}

##########################################################################
# ENVIRONMENT SET UP AND CHECKS
##########################################################################

RUNTIME_START=$(date +%s)

# constants
SCRIPT_VERSION=1.0

# sePATH_docker_pysradbt up pipeline scripts path
SCRIPT_PATH=$(cd $(dirname $0) && pwd)
MASTER_PATH=$SCRIPT_PATH/..

#docker images
IMAGE_pysradb='docker-pysradb'
PATH_docker_pysradb=$MASTER_PATH/$IMAGE_pysradb

IMAGE_plotmetadata='docker-plotmetadata'
PATH_docker_plotmetadata=$MASTER_PATH/$IMAGE_plotmetadata

# check the number of arguments
CURRENT_PIPELINE=$0
if [ $# -lt 3 ]; then
	echo "Cannot run pipeline - some arguments missing. Usage: $CURRENT_PIPELINE <"query string"> <output_dir_absolute_path> <metics_file_format> ( pdf or html )"
  exit 1
fi

##########################################################################
# ARGUMENTS
##########################################################################

query=$1 
outputdir=$2 
format=$3

if [ ! -d ${outputdir} ]; then
        echo "Output directory $outputdir doesn't exist!"
 	exit 1
fi

##########################################################################
# FILES
##########################################################################

file_string=`echo $query | tr " " "_"`

metadata_table=$file_string"_Table.tab"

if [ "$format" == "pdf" ]; then
	metadata_report=$file_string"_Report.pdf"
	output_format="pdf_document"
elif [ "$format" == "html" ]; then
	metadata_report=$file_string"_Report.html"
	output_format="html_document"
else
	echo "Please specify metics_file_format as pdf or html"
	exit 1
fi
###############################################################
# LOG FILE
###############################################################

RUNTIME_START=$(date +%s)
date_str=`date +"%y-%m-%d"`
log_file=${outputdir}"/"$file_string".log"

echo $log_file
# initilize log_file
touch $log_file

echo "*************************************** START ***************************************" >& $log_file

infomsg $log_file "Pipeline $CURRENT_PIPELINE $SCRIPT_VERSION started"
infomsg $log_file "Query : $query"
infomsg $log_file "Output directory : $outputdir"
infomsg $log_file "Metadata report format : $format"
infomsg $log_file "Log : $log_file"
infomsg $log_file "Output table : $outputdir/$metadata_table"
infomsg $log_file "Output report : $outputdir/$metadata_report"

###############################################################
# CHECK TOOLS AND INSTALL
###############################################################

# check that docker daemon is available on the system
checkinstalledtool docker  $log_file

# make images and evaluate
cd $PATH_docker_pysradb
docker build -t $IMAGE_pysradb . --network=host >> $log_file 2>&1
checkdockerimagepull $IMAGE_pysradb $log_file 
infomsg $log_file "Docker image $IMAGE_pysradb created"

cd $PATH_docker_plotmetadata
docker build -t $IMAGE_plotmetadata . --network=host >> $log_file 2>&1
checkdockerimagepull $IMAGE_plotmetadata $log_file
infomsg $log_file "Docker image $IMAGE_plotmetadata created"

###############################################################
# GET METADATA 
###############################################################

cd $outputdir

CMD="docker run --rm -it -u \"$(id -u):$(id -g)\" --network=host -v ${outputdir}/:/home/dockeruser/data/:rw $IMAGE_pysradb python search_sra_db.py \"$query\" /home/dockeruser/data/$metadata_table >> $log_file 2>&1"

executecmd "$CMD" $log_file

###############################################################
# METRICS REPORT FROM METADATA
###############################################################

if [ -s "$outputdir/$metadata_table" ] ; then
	infomsg $log_file "Output table : $outputdir/$metadata_table created. Continue with metrics report."
	if [ "$format" == "pdf" ]; then
		CMD1="docker run -it -u \"$(id -u):$(id -g)\" --rm -v ${outputdir}/:/home/dockeruser/data/:rw $IMAGE_plotmetadata Rscript -e \"rmarkdown::render('/home/dockeruser/code/makeMetadataReport.Rmd', output_format='pdf_document', output_file='/home/dockeruser/data/metadataReport.pdf')\" \"$query\" /home/dockeruser/data/$metadata_table >> $log_file 2>&1"
	        executecmd "$CMD1" $log_file
	elif [ "$format" == "html" ]; then
		CMD1="docker run -it --rm -v ${outputdir}/:/home/dockeruser/data/:rw $IMAGE_plotmetadata Rscript -e \"rmarkdown::render('/home/dockeruser/code/makeMetadataReport.Rmd', output_format='html_document', output_file='/home/dockeruser/data/metadataReport.html')\" \"$query\" /home/dockeruser/data/$metadata_table >> $log_file 2>&1"
		executecmd "$CMD1" $log_file
	fi
else
	exitmsg $log_file "File $outputdir/$metadata_table does not exist. Cannot make report."
fi

# remove temporary folder
rm -rf ${outputdir}/figs_tmp

# rename files 
if [ -s "$outputdir/metadataReport.pdf" ]; then
	mv $outputdir/metadataReport.pdf "$outputdir/$metadata_report"
elif [ -s "$outputdir/metadataReport.html" ]; then
	mv $outputdir/metadataReport.html "$outputdir/$metadata_report"
else 
	exitmsg $log_file "File $outputdir/$metadata_report does not exist. Pipeline did not finish."
fi

###############################################################
# FINISH
###############################################################

if [ -s "$outputdir/$metadata_report" ]; then
	infomsg $log_file "Output report : $outputdir/$metadata_report created. Pipeline completed"
        RUNTIME_END=$(date +%s)
        infomsg $log_file "Pipeline elapsed time: "$(($RUNTIME_END-$RUNTIME_START))"s."
	infomsg $log_file "*************************************** END ***************************************"
	exit 0
else
	exitmsg $log_file "File $outputdir/$metadata_report does not exist. Pipeline did not finish."

fi

###############################################################
# END
###############################################################

