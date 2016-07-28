echo "Dsen: Downloader for Sentinels Scientific Data Hub"
echo "====================================================="
echo "Inital Configuration"
echo ""

export USR=""
export PWD=""
export OUTDIR="output"
export TO_DOWNLOAD="product"

if [[ -z $USR ]]; then
	read -p "Enter username: " VAL
	export USR=$VAL
	printf "\n"
fi

if [[ -z $PWD ]]; then
	read -s -p "Enter password: " VAL
	export PWD=$VAL
	printf "\n\n"
fi

read -p "Enter output folder name [output]: " VAL
if [[ ! -z $VAL ]]; then
	export OUTDIR="${VAL}"
fi
printf "\n"

export WC="wget --no-check-certificate"
export AUTH="--user=${USR} --password=${PWD}"

export NAMEFILERESULTS="search_result.xml"

if [[ -d $OUTDIR ]]; then
	mkdir $OUTDIR
fi

if [[ -f $NAMEFILERESULTS ]]; then
	rm $NAMEFILERESULTS
fi

echo "==================================================="
echo "INPUT PARAMETER (Press ENTER if default, value in [])"
echo ""

export PLATFORM="Sentinel-1"
export LOC=""
export DATEF="NOW-1MONTH"
export DATET="NOW"
export PRODUCT="GRD"
export POLAR=""
export MODE="IW"
export RESOLU=""
export DIREC=""

# What if 2 of them are used
read -p "Enter Flatform (Sentinel-1, Sentinel-2) [Sentinel-1]: " VAL
if [[ ! -z $VAL ]];then
	export PLATFORM=$VAL
fi
printf "\n"

read -p "Enter Coordinate (P1Lon P1Lat, P2Lon P2Lat, …, PnLon PnLat, P1Lon P1Lat) [all]: " VAL
if [[ ! -z $VAL ]];then
	export LOC="(${VAL})"
	echo $LOC
fi
printf "\n"

read -p "Enter Start Date (yyyy-mm-dd HH:MM:SS) [1 month from now]: " VAL
# TODO: not null check
if [[ ! -z $VAL ]];then
	export DATEF=$VAL
fi
printf "\n"

read -p "Enter Coordinate (yyyy-mm-dd HH:MM:SS) [now]: " VAL
if [[ ! -z $VAL ]];then
	export DATET=$VAL
fi
printf "\n"

read -p "Enter Product (SLC, GRD, OCN, S2MSI1C) [GRD]: " VAL
if [[ ! -z $VAL ]];then
	export PRODUCT=$VAL
fi
printf "\n"

read -p "Enter Polarisation (HH, VV, HV, VH, HH HV, VV VH) [all]: " VAL
if [[ ! -z $VAL ]];then
	export POLAR=$VAL
fi
printf "\n"

read -p "Enter Sensor Operational Mode (SM, IW, EW) [IW]: " VAL
if [[ ! -z $VAL ]];then
	export MODE=$VAL
fi
printf "\n"

read -p "Enter Resolution(Full, High, Medium) [all]: " VAL
if [[ ! -z $VAL ]];then
	export RESOLU=$VAL
fi
printf "\n"

read -p "Enter Orbit Direction (Ascending, Descending) [all]): " VAL
if [[ ! -z $VAL ]];then
	export DIREC=$VAL
fi
printf "\n"


#export loc="footprint:\"Intersects(POLYGON((-10.452155411566443 35.96756889555928,1.4698695076076014 35.96756889555928,1.4698695076076014 44.19817173875521,-10.452155411566443 44.19817173875521,-10.452155411566443 35.96756889555928)))\""
#export loc=""
#export date="beginPosition:[2016-06-01T00:00:00.000Z TO 2016-06-30T23:59:59.999Z]endPosition:[2016-06-01T00:00:00.000Z TO 2016-06-30T23:59:59.999Z]"
#export platform="platformname:Sentinel-1"
#export prod="producttype:GRD"
#export mode="sensoroperationalmode:IW"
#export mode=""
#export direction="orbitdirection:Descending"
#export reso="medium"

export DHUS_DEST="https://scihub.copernicus.eu/dhus/"
export QUERY="search?q=*"


export LIMIT_QUERY="&rows=1000&start=0"

# MAKE QUERY
# TODO: currently not so robust
# TODO: remove tunning params
export QUERY_STATEMENT="${DHUS_DEST}${QUERY}"

export PLATFORM="Sentinel-1"
export LOC=""
export LOC="(-10.452155411566443 35.96756889555928,1.4698695076076014 35.96756889555928,1.4698695076076014 44.19817173875521,-10.452155411566443 44.19817173875521,-10.452155411566443 35.96756889555928)"
export DATEF="2016-06-01T00:00:00.000Z"
export DATET="2016-06-02T00:00:00.000Z"
export PRODUCT="GRD"
export POLAR=""
export MODE="IW"
export RESOLU=""
export DIREC=""

if [[ ! -z $RESOLU ]]; then
	export QUERY="${QUERY} AND ${RESOLU}"
fi

if [[ ! -z $PLATFORM ]]; then
	export QUERY="${QUERY} AND platformname:${PLATFORM}"
fi

if [[ ! -z $LOC ]]; then
	# TODO: loc format
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

${WC} ${AUTH} -O "${NAMEFILERESULTS}" "${QUERY_STATEMENT}"
sleep 5

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
if [ -z $PRODUCTLIST ];then
   export PRODUCTLIST="products-list.csv"
fi
cp .product_list_withlink $PRODUCTLIST
cat $PRODUCTLIST | cut -f2 -d$'\t' > .products-list-tmp.csv
cat .products-list-tmp.csv | grep -v 'https' > .list_name_products.csv
cat .products-list-tmp.csv | grep 'https' > .list_link_to_products.csv
paste -d',' .list_name_products.csv .list_link_to_products.csv > $PRODUCTLIST 
rm .product_list_withlink .products-list-tmp.csv .list_name_products.csv .list_link_to_products.csv  
export rv=0

# download via wget, link info from INPUT_FILE
export INPUT_FILE=product_list
mkdir -p $OUTDIR

#Xargs works here as a thread pool, it launches a download for each thread (P 2), each single thread checks 
#if the download is completed succesfully.
#The condition "[[ $? -ne 0 ]] || break" checks the first operand, if it is satisfied the break is skipped, instead if it fails 
#(download completed succesfully (?$=0 )) the break in the OR is executed exiting from the intitial "while".
#At this point the current thread is released and another one is launched.
if [ -f .failed.control.now.txt ]; then
    rm .failed.control.now.txt
fi

THREAD_NUMBER=2

mkdir logs/

cat ${INPUT_FILE} | xargs -n 4 -P ${THREAD_NUMBER} sh -c ' while : ; do
	echo "Downloading product ${3} from link ${DHUS_DEST}/odata/v1/Products('\''"$1"'\'')/\$value"; 
        ${WC} ${AUTH} ${TRIES} --progress=dot -e dotbytes=10M -c --output-file=./logs/log.${3}.log -O $OUTDIR/${3}".zip" "${DHUS_DEST}/odata/v1/Products('\''"$1"'\'')/\$value";
	test=$?;
	if [ $test -eq 0 ]; then
		echo "Product ${3} successfully downloaded at " `tail -2 ./logs/log.${3}.log | head -1 | awk -F"(" '\''{print $2}'\'' | awk -F")" '\''{print $1}'\''`;
		remoteMD5=$( ${WC} -qO- ${AUTH} ${TRIES} -c "${DHUS_DEST}/odata/v1/Products('\''"$1"'\'')/Checksum/Value/$value" | awk -F">" '\''{print $3}'\'' | awk -F"<" '\''{print $1}'\'');
		# openssl: crytograph toolkit
		localMD5=$( openssl md5 $OUTDIR/${3}".zip" | awk '\''{print $2}'\'');
		localMD5Uppercase=$(echo "$localMD5" | tr '\''[:lower:]'\'' '\''[:upper:]'\'');
		#localMD5Uppercase=1;
		if [ "$remoteMD5" == "$localMD5Uppercase" ]; then
			echo "Product ${3} successfully MD5 checked";
		else
		echo "Checksum for product ${3} failed";
		echo "${0} ${1} ${2} ${3}" >> .failed.control.now.txt;
		if [ ! -z $save_products_failed ];then  
		      rm $OUTDIR/${3}".zip"
		fi
		fi; 
	fi;
        break;
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
echo 'the end'
