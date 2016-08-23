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

if [[ -f $DIR/$OUTFOLDER ]]; then
	mkdir -p $DIR/$OUTFOLDER/$CALIB_FOLDER
fi

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
		# Use default calibration
		gpt.sh Calibration -Ssource={} -t ${outfile}'
)

echo "Single Files The end"
