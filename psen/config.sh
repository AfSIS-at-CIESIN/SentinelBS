#!/bin/bash

export PATH=$PATH":/opt/snap/bin/"
export GPT="gpt"

export TESTFLAG=0

export CALIB_FOLDER="calib.tmp"
export MOSAIC_FOLDER="mosaic.tmp"

if [[ $TESTFLAG -eq 1 ]]; then
	export DIR="/home/mwang/sentinel/psen/test"
	export INFOLDER="infile"
	export OUTFOLDER="output"
	
	echo "TEST in " $DIR
else
	export DIR="/data2/sentinel1"
	export INFOLDER="ghana"
	export OUTFOLDER="analysis"
	
	echo "RUN in " $DIR
fi

export GRAPH_FOLDER="graph"
export PREPROCESS="preprocessing_SNAP.xml"
export MOSAIC="mosaic_SNAP.xml"

# parallel by xargs for loop
# max p allowed by server before crush
export MAXP=10
export NP=$MAXP

