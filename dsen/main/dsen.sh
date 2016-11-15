#!/bin/bash

path=`dirname $0`

for i in `seq 0 100 10000`
do
    bash $path/oneloop.sh $1 $i
done
