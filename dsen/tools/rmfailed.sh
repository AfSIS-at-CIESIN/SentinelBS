export OUTDIR="output"
export ZIP="zip"
cd $OUTDIR

#cat failed_MD5_check_list.txt | cut -f4 -d ' ' | awk '{print "zip/"$1".zip"}' | xargs rm
#cat failed_MD5_check_list.txt | cut -f4 -d ' ' | awk '{print "zip/"$1".zip"}' | xargs sh -c 'while echo ${2}'
for f in $ZIP/*
do
	#echo $f
	export in_failure_log=`grep $(basename $f | cut -f1 -d ".") failed_MD5_check_list.txt`
	if [[ ! -z $in_failure_log ]];then
		echo "in"
	fi
	#if [[ ! -s $f ]];then
	#	echo $f >> failurelog.txt
	#	rm $f
	#else
	#	echo $f >> successlog.txt
	#fi
done

