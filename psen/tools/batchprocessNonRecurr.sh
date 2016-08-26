#!/bin/bash
source config.sh

# Batch cleaning via sentinenl 1 toolbox
echo ""
echo "Batch Processing Tool for Sentinel1 Data"
echo "Part II: Merging images"
echo "========================================"

mkdir -p $DIR/$OUTFOLDER
mkdir -p $DIR/$OUTFOLDER/$CALIB_FOLDER

export FILELIST=""

for f in $DIR/$OUTFOLDER/$CALIB_FOLDER/*.dim
do
	export FILELIST=${FILELIST}","$f
done

export FILELIST=`echo $FILELIST | cut -c 2-`
echo "FILELIST"
echo $FILELIST

export MOSAICNAME=`date +"%Y%m%d%H%M"`"_Mosaic.dim"


merge(){
	$GPT $GRAPH_FOLDER/$MOSAIC -PfileList=$FILELIST -Ptarget=$DIR/$OUTFOLDER/$MOSAICNAME -x
}

RES=`divide $FILELIST`

chmod 777 $DIR/$OUTFOLDER/$MOSAICNAME

echo "Final Mosaic"i$RES
echo "Batch files The end"
