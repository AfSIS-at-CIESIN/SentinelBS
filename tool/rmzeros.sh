export ZIP="../output/zip/"

echo "ZIP FILES DOWNLOAD SUCCEEDED LOG" > successlog.txt
echo "ZIP FILES DOWNLOAD FAILED LOG" > failurelog.txt

for f in $ZIP/*
do
	#echo $f
	if [[ ! -s $f ]];then
		echo $f >> failurelog.txt
		rm $f
	else
		echo $f >> successlog.txt
	fi
done

echo 'the end'
