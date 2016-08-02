export TESTD="tool/testrepo/"
export OUTD="output/zip/"

export ALL="S1A_IW_GRDH_1SDV_20160323T175352_20160323T175417_010500_00F972_77E4.zip"

export ZIPDIR=$OUTD
export USER="yzhan"
export ADDR="afsisdata2.ciesin.columbia.edu"
export DEST="/home/yzhan/"
export CONT=$ALL
cd $ZIPDIR

scp $CONT $USER@$ADDR:$DEST
