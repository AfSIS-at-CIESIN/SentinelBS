#!/bin/bash

# necessary config, dont alter unless you know what you're doing
export PATH=$PATH":/opt/snap/bin/"
export GPT="gpt"
# parallel by xargs for loop
# max p allowed by server before crush
export MAXP=10
export NP=$MAXP
# flag for debugging and testing
export TESTFLAG=0

# output folder info
export CALIB_FOLDER="calib.tmp"
export MOSAIC_FOLDER="mosaic.tmp"

export DIR="/data2/sentinel1"
export INFOLDER="ghana/2016s1"
export OUTFOLDER="analysis/2016s1"

echo "RUN in " $DIR

# user-defined graph location
export GRAPH_FOLDER="/home/mwang/sentinel/psen/graph"
export PREPROCESS="preprocessing_SNAP_beam.xml"
export MOSAIC="mosaic_SNAP_beam.xml"


