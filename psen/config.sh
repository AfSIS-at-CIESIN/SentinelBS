#!/bin/bash

export PATH=$PATH":/opt/S1TBX/"

export TESTFLAG=0

export DIR="/data2/sentinel1"
export INFOLDER="ghana"
export OUTFOLDER="analysis"
export CALIB_FOLDER=".calib.tmp"
	
export GRAPH_FOLDER="graph"
export CALIB="PreprocessingGraph.xml"
export MOSAIC="MosaicGraph.xml"

# parallel by xargs for loop
# max p allowed by server before crush
export MAXP=4
export NP=$MAXP

