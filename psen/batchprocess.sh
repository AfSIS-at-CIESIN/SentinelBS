#!/bin/bash
source config.sh

# Batch cleaning via sentinenl 1 toolbox
echo "Batch Processing Tool for Sentinel1 Data"
echo "========================================"

if [[ $TESTFLAG -eq 1 ]]; then
	export DIR="."
	export INFOLDER="infile"
	export OUTFOLDER="output"
	export CALIB_FOLDER=".calib.tmp"
	
	echo "TEST in " $DIR
else
	echo "RUN in " $DIR
fi

export FILELIST=""

for f in $DIR/$OUTFOLDER/$CALIB_FOLDER/*.dim
do
	export FILELIST=${FILELIST}","$f
done

export FILELIST=`echo $FILELIST | cut -c 2-`
echo "FILELIST"
echo $FILELIST

export MOSAICNAME=`date +"%Y%m%d%H%M"`"_Mosaic.dim"
gpt.sh $GRAPH_FOLDER/$MOSAIC -Pfilelist=$FILELIST -t $DIR/$OUTFOLDER/$MOSAICNAME -q 16

rm -rf $DIR/OUTFOLDER/CALIB
chmod 777 $DIR/$OUTFOLDER/$MOSAICNAME
echo "Batch files The end"
