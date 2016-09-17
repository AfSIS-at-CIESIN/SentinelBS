#!/bin/bash

mkdir -p log
for f in tasks/*.sh
do
  prefix=`basename $f`
  bash $f 1> log/$prefix'.out' 2> log/$prefix'.err'
done
