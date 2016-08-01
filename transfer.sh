export TESTD="tool/testrepo/"
export OUTD="output/zip/"

export ALL="*"

export ZIPDIR=$TESTD
export USER="pi"
export ADDR="160.39.56.111"
export DEST="/home/pi/"
export CONT=$ALL
cd $ZIPDIR

scp $CONT $USER@$ADDR:$DEST
