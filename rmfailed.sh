export OUTDIR="output"
export ZIP="zip"
cd $OUTDIR

cat failed_MD5_check_list.txt | cut -f4 -d ' ' | awk '{print "zip/"$1".zip"}' | xargs rm
