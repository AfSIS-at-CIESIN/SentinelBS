# Batch cleaning via sentinenl 1 toolbox
export infolder="infile"
export outfolder="output"
export graph="ReadWriteGraph.xml"

for f in $infolder/*
do
	echo $f
	export name=`basename $f`
	./gpt.sh $graph $f -t $outputfolder/$name".dim"
done
