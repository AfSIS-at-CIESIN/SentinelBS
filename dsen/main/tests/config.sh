export USR="emmanuelshs"
export PWD="Ciesin2016"

# loc
export GHANA="(-3.3368297113536087 4.394202020378941,1.4284107877773324 4.394202020378941,1.4284107877773324 11.110218557903721,-3.3368297113536087 11.110218557903721,-3.3368297113536087 4.394202020378941)"

# basic default configuration
export OUTDIR=`dirname $0`"/../output"

# the hub allows no more than 2 downloads at same time
export THREAD_NUMBER=2

export PLATFORM="Sentinel-1"
export LOC=$GHANA
export DATEF="2016-01-01T00:00:00.000Z"
export DATET="2016-03-31T23:59:59.999Z"
export PRODUCT="GRD"
export POLAR=""
export MODE="IW"
export RESOLU="high"
export DIREC=""

# error
export NETWORKERROR="ERROR 503: Service Unavailable."

