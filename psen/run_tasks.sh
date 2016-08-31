#!/bin/bash

mkdir -p log

for f in `ls -1 tasks/`
do 
  prefix=`basename $f`
  bash $f 1> $prefix'.out' 2> $prefix'.err'
done
