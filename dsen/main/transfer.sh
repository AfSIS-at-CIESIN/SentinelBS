export TESTD="tool/testrepo/"
export OUTMAIN="/vega/afsis/users/mw3065/sentinel1/ghana/"
export OUTSUB="/zip/"
export SEASON=("2015s4")

export YANNI="yzhan"
export MENGQ="mwang"

export ALL="*"
export ONE="S1A_IW_GRDH_1SDV_20160323T175352_20160323T175417_010500_00F972_77E4.zip"

export ZIPDIR=$OUTD
export USER=$MENGQ
export ADDR="afsisdata2.ciesin.columbia.edu"
export DEST="/data2/sentinel1/ghana/"
export CONT=$ALL
cd $ZIPDIR

# scp $CONT $USER@$ADDR:$DEST
for s in ${SEASON[@]}
do
  echo $s
  # rsync -av --ignore-existing $OUTD $USER@$ADDR:$DEST
  rsync -av $OUTMAIN$s$OUTSUB $USER@$ADDR:$DEST$s
done
