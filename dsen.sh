echo "Dsen: Downloader for Sentinels Scientific Data Hub"
echo "====================================================="

export usr=""
export pwd=""

if [[ -z $usr ]]; then
	read -p "Enter username: " VAL
	export usr=$VAL
	printf "\n"
fi

if [[ -z $pwd ]]; then
	read -s -p "Enter password: " VAL
	export pwd=$VAL
	printf "\n\n"
fi


export WC="wget --no-check-certificate"
export AUTH="--user=${usr} --password=${pwd}"

export FEEDXML=".feed.out.tmp"

if [[ -f $FEEDXML ]]; then
	rm $FEEDXML
fi

export URLORG="https://scihub.copernicus.eu/dhus/"
export QUERY="search?q="


export loc="footprint:\"Intersects(POLYGON((-10.452155411566443 35.96756889555928,1.4698695076076014 35.96756889555928,1.4698695076076014 44.19817173875521,-10.452155411566443 44.19817173875521,-10.452155411566443 35.96756889555928)))\""
export date="beginPosition:[2016-06-01T00:00:00.000Z TO 2016-06-30T23:59:59.999Z]endPosition:[2016-06-01T00:00:00.000Z TO 2016-06-30T23:59:59.999Z]"
export platform="platformname:Sentinel-1"
export prod="producttype:GRD"
export mode="sensoroperationalmode:IW"
export direction="orbitdirection:Descending"
export reso=""

export rows="&rows=1000"
export start="&start=0"

if [[ ! -z $loc ]]; then
	export QUERY_STATEMENT="${URLORG}${QUERY}${loc}"
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

if [[ ! -z $reso ]]; then
	export QUERY_STATEMENT="${QUERY_STATEMENT} AND ${reso}"
fi

if [[ ! -z $rows ]]; then
	export QUERY_STATEMENT="${QUERY_STATEMENT}${rows}"
fi

if [[ ! -z $start ]]; then
	export QUERY_STATEMENT="${QUERY_STATEMENT}${start}"
fi

${WC} ${AUTH} -O "${$FEEDXML}" "${QUERY_STATEMENT}"
