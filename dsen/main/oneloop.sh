#!/bin/bash

# Read in from commandline
export CONFIG=$1
if [[ -z $CONFIG ]]; then
  echo "Using Default Config File"
  export CONFIG=`dirname $0`'/../config/config.sh'
fi

source $CONFIG

echo "Dsen: Downloader for Sentinels Scientific Data Hub"

# PARSE NON-INTERACTIVE FLAGS

# INTERACTIVE MODE (Depreciated)
echo "====================================================="

export WC="wget --no-check-certificate"
export AUTH="--user=${USR} --password=${PWD}"

export ZIP="zip"
export NAMEFILERESULTS="search_result.xml"

#
mkdir -p $OUTDIR
cd $OUTDIR


# MAKE QUERY
export DHUS_DEST="https://scihub.copernicus.eu/dhus/"
export QUERY="search?q=*"
export LIMIT_QUERY="&rows=100""&start="$2

# For Tunning Only
#export PLATFORM="Sentinel-1"
#export LOC="(-10.452155411566443 35.96756889555928,1.4698695076076014 35.96756889555928,1.4698695076076014 44.19817173875521,-10.452155411566443 44.19817173875521,-10.452155411566443 35.96756889555928)"
#export DATEF="2016-06-01T00:00:00.000Z"
#export DATET="2016-06-02T00:00:00.000Z"
#export PRODUCT="GRD"
#export POLAR=""
#export MODE="IW"
#export RESOLU=""
#export DIREC=""

if [[ ! -z $RESOLU ]]; then
	export QUERY="${QUERY} AND ${RESOLU}"
fi

if [[ ! -z $PLATFORM ]]; then
	export QUERY="${QUERY} AND platformname:${PLATFORM}"
fi

if [[ ! -z $LOC ]]; then
	export QUERY="${QUERY} AND footprint:\"Intersects(POLYGON(${LOC}))\""
fi

if [[ ! -z $DATEF && ! -z $DATET ]]; then
	export QUERY="${QUERY} AND beginPosition:[${DATEF} TO ${DATET}] AND endPosition:[${DATEF} TO ${DATET}]"
fi

if [[ ! -z $PRODUCT ]]; then
	export QUERY="${QUERY} AND producttype:${PRODUCT}"
fi

if [[ ! -z $POLAR ]]; then
	export QUERY="${QUERY} AND ${POLAR}"
fi

if [[ ! -z $MODE ]]; then
	export QUERY="${QUERY} AND sensoroperationalmode:${MODE}"
fi

if [[ ! -z $DIREC ]]; then
	export QUERY="${QUERY} AND orbitdirection:${DIREC}"
fi

export QUERY_STATEMENT="${DHUS_DEST}${QUERY}${LIMIT_QUERY}"
echo $QUERY_STATEMENT

export SLEEPTIME=300

export test=1
# fault tolerant via $?
while [[ ! test -eq 0 ]]
do
	${WC} ${AUTH} -O "${NAMEFILERESULTS}" "${QUERY_STATEMENT}" 2> .searcherrinfo
	export test=$?

	export ERR=`cat .searcherrinfo | awk '/./{line=$0} END{print line}'`
	echo $ERR
	if [[ "${ERR}" == *"${NETWORKERROR}"* ]];then
		ne=1
	else 
		ne=0
	fi
	
	if [[ ! ne -eq 0 && ! test -eq 0 ]];then
		echo "network error, sleep ${SLEEPTIME} s."
		sleep ${SLEEPTIME}
	fi

	rm -f .searcherrinfo
done

# Use NAMEFILERESULTS to Prepare downlaod main files
cat "${NAMEFILERESULTS}" | grep '<id>' | tail -n +2 | cut -f2 -d'>' | cut -f1 -d'<' | cat -n > .product_id_list

cat "${NAMEFILERESULTS}" | grep '<link rel="alternative" href=' | cut -f4 -d'"' | cat -n | sed 's/\/$//'> .product_link_list

cat "${NAMEFILERESULTS}" | grep '<title>' | tail -n +2 | cut -f2 -d'>' | cut -f1 -d'<' | cat -n > .product_title_list
if [ ! -z $TIMEFILE ];then
if [ `cat "${NAMEFILERESULTS}" | grep '="ingestiondate"' |  head -n 1 | cut -f2 -d'>' | cut -f1 -d'<' | wc -l` -ne 0 ];
then
	lastdate=`cat "${NAMEFILERESULTS}" | grep '="ingestiondate"' |  head -n 1 | cut -f2 -d'>' | cut -f1 -d'<'`;
	years=`echo $lastdate | tr "T" '\n'|head -n 1`;
	hours=`echo $lastdate | tr "T" '\n'|tail -n 1`;
	echo `date +%Y-%m-%d --date="$years"`"T"`date +%T.%NZ -u --date="$hours + 0.001 seconds"`> $TIMEFILE
fi 
fi

paste -d\\n .product_id_list .product_title_list | sed 's/[",:]/ /g' > product_list

cat .product_title_list .product_link_list | sort -k1n,1 -k2r,2 | sed 's/[",:]/ /g' | sed 's/https \/\//https:\/\//' > .product_list_withlink

rm -f .product_id_list .product_link_list .product_title_list .product_ingestion_time_list

echo ""

cat "${NAMEFILERESULTS}" | grep '<subtitle>' | cut -f2 -d'>' | cut -f1 -d'<' | cat -n

NPRODUCT=`cat "${NAMEFILERESULTS}" | grep '<subtitle>' | cut -f2 -d'>' | cut -f1 -d'<' | cat -n | cut -f11 -d' '`;
 
echo ""

if [ "${NPRODUCT}" == "0" ]; then exit 1; fi

cat .product_list_withlink

export PRODUCTLIST=products-list.csv

cp .product_list_withlink $PRODUCTLIST
cat $PRODUCTLIST | cut -f2 -d$'\t' > .products-list-tmp.csv
cat .products-list-tmp.csv | grep -v 'https' > .list_name_products.csv
cat .products-list-tmp.csv | grep 'https' > .list_link_to_products.csv
paste -d',' .list_name_products.csv .list_link_to_products.csv > $PRODUCTLIST 
rm .product_list_withlink .products-list-tmp.csv .list_name_products.csv .list_link_to_products.csv  
export rv=0

# download via wget, link info from INPUT_FILE
export INPUT_FILE=product_list
mkdir -p $ZIP

# mv prev failed MD5 file to history
if [[ -s failed_MD5_check_list.txt ]];then
	if [[ -s failed_MD5_check_list_history.txt ]]; then
		date >> failed_MD5_check_list_history.txt
		cat failed_MD5_check_list.txt >> failed_MD5_check_list_history.txt
	else
		date > failed_MD5_check_list_history.txt
		cat failed_MD5_check_list.txt > failed_MD5_check_list_history.txt
	fi
	rm failed_MD5_check_list.txt
fi

#Xargs works here as a thread pool, it launches a download for each thread (P 2), each single thread checks 
#if the download is completed succesfully.
#The condition "[[ $? -ne 0 ]] || break" checks the first operand, if it is satisfied the break is skipped, instead if it fails 
#(download completed succesfully (?$=0 )) the break in the OR is executed exiting from the intitial "while".
#At this point the current thread is released and another one is launched.
if [ -f .failed.control.now.txt ]; then
    rm .failed.control.now.txt
fi

export LOGS=logs
mkdir -p $LOGS

cat ${INPUT_FILE} | xargs -n 4 -P ${THREAD_NUMBER} sh -c ' while : ; do
	if [[ -s $ZIP/${3}".zip" ]]; then
		echo "Product ${3} already downloaded, skip"
		break
	fi

	echo "Downloading product ${3} from link ${DHUS_DEST}/odata/v1/Products('\''"$1"'\'')/\$value"; 
        ${WC} ${AUTH} -nc  --progress=dot -e dotbytes=10M -c --output-file=./$LOGS/log.${3}.log -O $ZIP/${3}".zip" "${DHUS_DEST}/odata/v1/Products('\''"$1"'\'')/\$value";
	test=$?;
	if [ $test -eq 0 ]; then
		echo "Product ${3} successfully downloaded at " `tail -2 ./$LOGS/log.${3}.log | head -1 | awk -F"(" '\''{print $2}'\'' | awk -F")" '\''{print $1}'\''`;
		remoteMD5=$( ${WC} -qO- ${AUTH} -c "${DHUS_DEST}/odata/v1/Products('\''"$1"'\'')/Checksum/Value/$value" | awk -F">" '\''{print $3}'\'' | awk -F"<" '\''{print $1}'\'');
		# openssl: crytograph toolkit
		localMD5=$( openssl md5 $ZIP/${3}".zip" | awk '\''{print $2}'\'');
		localMD5Uppercase=$(echo "$localMD5" | tr '\''[:lower:]'\'' '\''[:upper:]'\'');
		#localMD5Uppercase=1;
		if [ "$remoteMD5" == "$localMD5Uppercase" ]; then
			echo "Product ${3} successfully MD5 checked";
        		break;
		else
		echo "Checksum for product ${3} failed";
		echo "${0} ${1} ${2} ${3}" >> .failed.control.now.txt;
		rm -f $ZIP/${3}."zip";
		echo "Removed MD5-check-failed product ${3}, restart again";
		sleep 3;
		if [ ! -z $save_products_failed ];then  
		      rm $ZIP/${3}".zip"
		fi
		fi; 
	else
		echo "Product ${3} timeout during download, try again after ${SLEEPTIME} s."
		# failed file must be removed
		rm -f $ZIP/${3}."zip"
		sleep $SLEEPTIME
	fi;
done '

# MD5 check
CHECK_VAR=true

if [ ! -z $check_save_failed ]; then
    if [ -f .failed.control.now.txt ];then
    	mv .failed.control.now.txt $FAILED
    else 
    if [ ! -f .failed.control.now.txt ] && [ $CHECK_VAR == true ] && [ ! ISSELECTEDEXIT ];then
    	echo "All downloaded products have successfully passed MD5 integrity check"
    fi
    fi
else
    if [ -f .failed.control.now.txt ];then
    	 mv .failed.control.now.txt failed_MD5_check_list.txt
    else 
    if [ ! -f .failed.control.now.txt ] && [ $CHECK_VAR == true ] && [ ! ISSELECTEDEXIT ];then
    	echo "All downloaded products have successfully passed MD5 integrity check"
    fi
    fi
fi

# remove those which MD5 failed
#cat failed_MD5_check_list.txt | cut -f4 -d ' ' | awk '{print "zip/"$1".zip"}' | xargs rm


# remove empty files if exists
# redownload would skip non-empty ones
# and focus on zeros
echo "ZIP FILES DOWNLOAD SUCCEEDED LOG" > successlog.txt
echo "ZIP FILES DOWNLOAD FAILED LOG" > failurelog.txt

for f in $ZIP/*
do
	# rm MD5 failed ones
	export in_failure_log=`grep $(basename $f | cut -f1 -d ".") failed_MD5_check_list.txt`
	if [[ ! -z $in_failure_log ]];then
		rm $f
	fi

	if [[ ! -s $f ]];then
		echo $f >> failurelog.txt
		rm $f
	else
		echo $f >> successlog.txt
	fi
done

cd ../

echo 'the end'

