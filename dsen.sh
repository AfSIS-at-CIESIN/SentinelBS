echo "Dsen: Downloader for Sentinels Scientific Data Hub"
echo "====================================================="

export USR=""
export PWD=""

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


export WC="wget --no-check-certificate"
export AUTH="--user=${USR} --password=${PWD}"

export FEEDXML=".feed.out.tmp"

if [[ -f $FEEDXML ]]; then
	rm $FEEDXML
fi

export URLORG="https://scihub.copernicus.eu/dhus/"
export QUERY="search?q="


echo "==================================================="
echo "INPUT PARAMETER (Press ENTER if default, value in [])"

export RESOLU=""
export LOC=""
export DATEF="NOW-1MONTH"
export DATET="NOW"
export PLATFORM="Sentinel-1"
export PRODUCT="GRD"
export MODE="IW"
export POLAR=""
export DIREC=""

# What if 2 of them are used
read -p "Enter Resolution(Full, High, Medium) [all]: " VAL
if [[ -z $VAL ]];then
	export RESOLU=$VAL
fi
printf "\n"

read -p "Enter Coordinate ( ) [all]: " VAL
if [[ -z $VAL ]];then
	export LOC=""
fi
printf "\n"

read -p "Enter Start Date ( ) [1 month from now]: " VAL
if [[ -z $VAL ]];then
	export DATEF=$VAL
fi
printf "\n"

read -p "Enter Coordinate ( ) [now]: " VAL
if [[ -z $VAL ]];then
	export DATET=$VAL
fi
printf "\n"

read -p "Enter Flatform (Sentinel-1, Sentinel-2) [Sentinel-1]: " VAL
if [[ -z $VAL ]];then
	export PLATFORM=$VAL
fi
printf "\n"

read -p "Enter Product (SLC, GRD, OCN, S2MSI1C) [GRD]: " VAL
if [[ -z $VAL ]];then
	export PRODUCT=$VAL
fi
printf "\n"

read -p "Enter Sensor Operational Mode (SM, IW, EW) [IW]: " VAL
if [[ -z $VAL ]];then
	export MODE=$VAL
fi
printf "\n"

read -p "Enter Orbit Direction (Ascending, Descending) [all]): " VAL
if [[ -z $VAL ]];then
	export DIREC=$VAL
fi
printf "\n"

read -p "Enter Polarisation (HH, VV, HV, VH, HH HV, VV VH) [all]: " VAL
if [[ -z $VAL ]];then
	export POLAR=$VAL

fi
printf "\n"

export loc="footprint:\"Intersects(POLYGON((-10.452155411566443 35.96756889555928,1.4698695076076014 35.96756889555928,1.4698695076076014 44.19817173875521,-10.452155411566443 44.19817173875521,-10.452155411566443 35.96756889555928)))\""
export loc=""
export date="beginPosition:[2016-06-01T00:00:00.000Z TO 2016-06-30T23:59:59.999Z]endPosition:[2016-06-01T00:00:00.000Z TO 2016-06-30T23:59:59.999Z]"
export platform="platformname:Sentinel-1"
export prod="producttype:GRD"
export mode="sensoroperationalmode:IW"
export mode=""
export direction="orbitdirection:Descending"
export reso="medium"

export rows="&rows=1000"
export start="&start=0"

export QUERY_STATEMENT="${URLORG}${QUERY}"

if [[ ! -z $reso ]]; then
	export QUERY_STATEMENT="${QUERY_STATEMENT}${reso}"
fi

if [[ ! -z $loc ]]; then
	export QUERY_STATEMENT="${QUERY_STATEMENT} AND ${loc}"
fi

if [[ ! -z $date ]]; then
	export QUERY_STATEMENT="${QUERY_STATEMENT} AND ${date}"
fi

if [[ ! -z $platform ]]; then
	export QUERY_STATEMENT="${QUERY_STATEMENT} AND ${platform}"
fi

if [[ ! -z $prod ]]; then
	export QUERY_STATEMENT="${QUERY_STATEMENT} AND ${prod}"
fi

if [[ ! -z $mode ]]; then
	export QUERY_STATEMENT="${QUERY_STATEMENT} AND ${mode}"
fi

if [[ ! -z $rows ]]; then
	export QUERY_STATEMENT="${QUERY_STATEMENT}${rows}"
fi

if [[ ! -z $start ]]; then
	export QUERY_STATEMENT="${QUERY_STATEMENT}${start}"
fi

${WC} ${AUTH} -O "${FEEDXML}" "${QUERY_STATEMENT}"
