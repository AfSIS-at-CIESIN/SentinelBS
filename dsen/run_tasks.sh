# !/bin/bash

mkdir -p log
for f in tasks/*.sh
do
  echo $f
  prefix=`basename $f`
  bash $f > log/$prefix'.log'
done
