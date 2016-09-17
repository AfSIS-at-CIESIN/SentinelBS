# !/bin/bash

mkdir -p log
for f in tasks/*.sh
do
  echo $f
  prefix=`basename $f`
  bash $f 1> log/$prefix'.out' 2> log/$prefix'.err'
done
