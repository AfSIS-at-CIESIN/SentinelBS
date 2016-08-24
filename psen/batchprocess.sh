#!/bin/bash
source config.sh

# Batch cleaning via sentinenl 1 toolbox
echo ""
echo "Batch Processing Tool for Sentinel1 Data"
echo "Part II: Merging images"
echo "========================================"

export FILELIST=""

for f in $DIR/$OUTFOLDER/$CALIB_FOLDER/*.dim
do
	export FILELIST=${FILELIST}","$f
done

export FILELIST=`echo $FILELIST | cut -c 2-`
echo "FILELIST"
echo $FILELIST

export MOSAICNAME=`date +"%Y%m%d%H%M"`"_Mosaic.dim"
$GPT $GRAPH_FOLDER/$MOSAIC -PfileList=$FILELIST -Ptarget=$DIR/$OUTFOLDER/$MOSAICNAME -q 16

chmod 777 $DIR/$OUTFOLDER/$MOSAICNAME
echo "Batch files The end"
