echo 'Dsen: Downloader for Sentinels Scientific Data Hub'
echo '====================================================='
echo 'Inital Configuration'

export USR=''
export PWD=''
export OUTDIR='./output'

if [[ -z $USR ]]; then
	read -p 'Enter username: ' VAL
	export USR=$VAL
	printf '\n'
fi

if [[ -z $PWD ]]; then
	read -s -p 'Enter password: ' VAL
	export PWD=$VAL
	printf '\n\n'
fi

read -s -p 'Enter output folder name [output]: ' VAL
if [[ ! -z $VAL ]]; then
	export OUTDIR="./${VAL}"
fi
printf '\n\n'

export WC='wget --no-check-certificate'
export AUTH='--user=${USR} --password=${PWD}'

export FEEDXML='.feed.out.tmp'

if [[ -f $FEEDXML ]]; then
	rm $FEEDXML
fi

export URLORG='https://scihub.copernicus.eu/dhus/'
export QUERY='search?q='


echo '==================================================='
echo 'INPUT PARAMETER (Press ENTER if default, value in [])'

export PLATFORM='Sentinel-1'
export LOC=''
export DATEF='NOW-1MONTH'
export DATET='NOW'
export PRODUCT='GRD'
export POLAR=''
export MODE='IW'
export RESOLU=''
export DIREC=''

# What if 2 of them are used
read -p 'Enter Flatform (Sentinel-1, Sentinel-2) [Sentinel-1]: ' VAL
if [[ ! -z $VAL ]];then
	export PLATFORM=$VAL
fi
printf '\n'

read -p 'Enter Coordinate ( ) [all]: ' VAL
if [[! ! -z $VAL ]];then
	# TODO: loc format
	export LOC=$VAL
fi
printf '\n'

read -p 'Enter Start Date ( ) [1 month from now]: ' VAL
# TODO: not null check
if [[ ! -z $VAL ]];then
	export DATEF=$VAL
fi
printf '\n'

read -p 'Enter Coordinate ( ) [now]: ' VAL
if [[ ! -z $VAL ]];then
	export DATET=$VAL
fi
printf '\n'

read -p 'Enter Product (SLC, GRD, OCN, S2MSI1C) [GRD]: ' VAL
if [[ ! -z $VAL ]];then
	export PRODUCT=$VAL
fi
printf '\n'

read -p 'Enter Polarisation (HH, VV, HV, VH, HH HV, VV VH) [all]: ' VAL
if [[ ! -z $VAL ]];then
	export POLAR=$VAL
fi
printf '\n'

read -p 'Enter Sensor Operational Mode (SM, IW, EW) [IW]: ' VAL
if [[ ! -z $VAL ]];then
	export MODE=$VAL
fi
printf '\n'

read -p 'Enter Resolution(Full, High, Medium) [all]: ' VAL
if [[ ! -z $VAL ]];then
	export RESOLU=$VAL
fi
printf '\n'

read -p 'Enter Orbit Direction (Ascending, Descending) [all]): ' VAL
if [[ ! -z $VAL ]];then
	export DIREC=$VAL
fi
printf '\n'


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


# MAKE QUERY
# TODO: currently not so robust
export QUERY_STATEMENT="${URLORG}${QUERY}"

export PLATFORM='Sentinel-1'
export LOC=''
export DATEF='NOW-1MONTH'
export DATET='NOW'
export PRODUCT='GRD'
export POLAR=''
export MODE='IW'
export RESOLU=''
export DIREC=''

if [[ ! -z $PLATFROM ]]; then
	export QUERY="${QUERY}platformname:${PLATFORM}"
fi

if [[ ! -z $LOC ]]; then
	# TODO: loc format
	export QUERY="${QUERY} AND ${loc}"
fi

if [[ ! -z $DATEF && ! -z $DATET ]]; then
	export QUERY="${QUERY} AND beginPosition:[${DATEF} TO ${DATET}]endPosition:[${DATEF} TO ${DATET}]"
fi

if [[ ! -z $PRODUCT ]]; then
	export QUERY="${QUERY} AND ${PRODUCT}"
fi

if [[ ! -z $POLAR ]]; then
	export QUERY="${QUERY} AND ${POLAR}"
fi

if [[ ! -z $MODE ]]; then
	export QUERY="${QUERY} AND ${MODE}"
fi

if [[ ! -z $rows ]]; then
	export QUERY_STATEMENT="${QUERY_STATEMENT}${rows}"
fi

if [[ ! -z $start ]]; then
	export QUERY_STATEMENT="${QUERY_STATEMENT}${start}"
fi

${WC} ${AUTH} -O "${FEEDXML}" "${QUERY_STATEMENT}"

# Use FEEDXML to Prepare downlaod main files
