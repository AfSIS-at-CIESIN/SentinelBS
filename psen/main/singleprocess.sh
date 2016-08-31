#!/bin/bash

export CONFIG=$1
if [[ -z $CONFIG ]];then
  echo "Using Default Config File"
  export CONFIG=`dirname $0`'../config/config.sh'
fi
source $CONFIG

# Batch cleaning via sentinenl 1 toolbox
echo ""
echo "Batch Processing Tool for Sentinel1 Data"
echo "Part I: preprocessing"
echo "========================================"

mkdir -p $DIR/$OUTFOLDER
mkdir -p $DIR/$OUTFOLDER/$CALIB_FOLDER

for f in $DIR/$INFOLDER/*.zip
do
	echo $f
done |
(
	export PATH=$PATH":/opt/S1TBX/"
	xargs -I{} -P $NP sh -c '
		echo "processing {}"
		export name=`basename {} | cut -d '.' -f 1`
		export outfile=${DIR}/${OUTFOLDER}/${CALIB_FOLDER}/${name}".dim"
		${GPT} ${GRAPH_FOLDER}/${PREPROCESS} -Psource={} -Ptarget=${outfile}'
)

echo "Single Files The end"
