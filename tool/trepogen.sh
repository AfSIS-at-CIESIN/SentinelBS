export OUTDIR="testrepo"
cd $OUTDIR

for i in {1..10}
do
	echo $i > "test${i}.txt"
done
