# Batch cleaning via sentinenl 1 toolbox
export infolder="./infile/"
export outfolder="./output/"
export graph="./"

for f in $infolder/*
do
	export name=`basename $f`
	./gpt.sh $graph $f -t $outputfolder/$name".dim"
done
