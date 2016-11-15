#!/bin/bash

for i in `seq 0 100 10000`
do
    ./oneloop.sh $1 $i
done
