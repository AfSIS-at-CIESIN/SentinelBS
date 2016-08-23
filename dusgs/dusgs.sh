#!/bin/bash

source config.sh
source login.sh

# need export so inner loop can access
export URL_BASE="http://e4ftl01.cr.usgs.gov/"
#TEST=1
#
#PRODUCT="MOD13Q1"
#MONTH="06"
#YEAR="2016"
#H=( "16" "17" "18" "19" "20" "21" "22" "23" )
#V=( "09" "10" "11" "12" )
#VER="005"

if [[ $TEST -eq 1 ]]; then
	export OUTDIR="test/"
fi

# Get one folder
AUTH="--user=${USR} --password=${PWD}"
# -N would download if remote one is updated
export WC="wget -N -q -t 0 "$AUTH

clean_tmp()
{
	echo "CLEANING..."
	for tmp in `find $OUTDIR -regextype posix-extended -regex ".*\.tmp" -type f`
	do
		echo $tmp
		rm $tmp
	done
}

query_test()
{
	echo $1
	echo $2
	echo $3
}

query_one()
{
	printf "FETCHING "$3'\n'"From "$1'/'$3'\n'
	$WC $1'/'$3 -O $2'/'$3
	sleep 2
}

query_files()
{
	echo "QUERYING "$3
	URL_DATE=$1$3
	#echo $URL_DATE

	CURRDIR=$2$3
	mkdir -p $CURRDIR
	RAW=$CURRDIR'/'".filename.raw.tmp"
	TMP=$CURRDIR'/'".filename.tmp"
	RES=$CURRDIR'/'".filename.res.tmp"

	$WC $URL_DATE -O $RAW

	grep -o 'MOD\(.*\).hdf"' $RAW | cut -d '"' -f 1 > $TMP
	# rm $OUTDIR".filename.raw.tmp"

	# parse H & V
	IFS=' ' read -a H <<< $H
	IFS=' ' read -a V <<< $V
                     
	echo "" > $RES
	for h in ${H[@]}
	do 
		for v in ${V[@]}
		do
			grep "h"$h"v"$v $TMP >> $RES
		done
	done

	for f in `cat $RES`
	do
		echo $URL_DATE $CURRDIR $f
	done | xargs -n 3 -P 4 -I {} bash -c 'query_one $@' _ {}

	#rm $RAW $TMP $RES
}

query_folder()
{
	echo "PRODUCT "$3
	CURRDIR=$2$3'/'
	mkdir -p $CURRDIR
	RAW=$CURRDIR".foldername.raw.tmp"
	TMP=$CURRDIR".foldername.tmp"
	RES=$CURRDIR".foldername.res.tmp"

	URL=$1$3'/'
	$WC $URL -O $RAW

	grep -o '[[:digit:]]\{4\}\(\.[[:digit:]]\{2\}\)\{2\}' $RAW > $TMP

	grep $YEAR'.'$MONTH $TMP > $RES

	for datestr in `cat $RES`
	do
		echo $URL $CURRDIR $datestr
	# only bash -c possible this way
	done | xargs -n 3 -P 2 -I {} bash -c 'query_files $@' _ {}

	#rm $RAW $TMP $RES
}

export -f query_one
export -f query_test
export -f query_files
export -f query_folder

# DOWNLOAD in each year month folder
URL=$URL_BASE"MOLT/"
echo $URL

CURRDIR=$OUTDIR
mkdir -p $CURRDIR
query_folder $URL $CURRDIR $PRODUCT'.'$VER

chmod -R 777 $OUTDIR

clean_tmp

echo "DONE"
