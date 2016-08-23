# Batch cleaning via sentinenl 1 toolbox

export PATH=$PATH":/opt/S1TBX/"

echo "Batch Processing Tool for Sentinel1 Data"
echo "========================================"

export TESTFLAG=0

if [[ $TESTFLAG -eq 1 ]]; then
	export DIR="."
	export INFOLDER="infile"
	export OUTFOLDER="output"
	export CALIB_FOLDER=".calib.tmp"
	
	echo "TEST in " $DIR
else
	export DIR="/data2/sentinel1"
	export INFOLDER="ghana"
	export OUTFOLDER="analysis"
	export CALIB_FOLDER=".calib.tmp"
	
	echo "RUN in " $DIR
fi

export GRAPH_FOLDER="graph"
export CALIB="PreprocessingGraph.xml"
export MOSAIC="MosaicGraph.xml"

if [[ -f $DIR/$OUTFOLDER ]]; then
	mkdir -p $DIR/$OUTFOLDER/$CALIB_FOLDER
fi

mkdir -p $DIR/$OUTFOLDER
mkdir -p $DIR/$OUTFOLDER/$CALIB_FOLDER

# parallel by xargs for loop
# max p allowed by server before crush
export MAXP=4
export NP=$MAXP

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
echo "The end"
