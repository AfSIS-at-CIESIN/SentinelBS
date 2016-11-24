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
export CALIB_FOLDER=
export MOSAIC_FOLDER=

export DIR=
export INFOLDER=
export OUTFOLDER=

echo "RUN in " $DIR

# user-defined graph location
export GRAPH_FOLDER=
export PREPROCESS=
export MOSAIC=


