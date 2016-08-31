#!/bin/bash

c=0

while [[ 1 ]]
do 
  n=`ps -ef | grep 'mwang' | grep '/opt/snap/jre/bin/java' | wc -l`
  echo "Present running thread: "$n

  if [[ n -eq 0 ]]; then
    if [[ c -lt 2 ]]; then
      echo "Pgm finished, exit"
      exit
    fi

    sleep 5

  else
    sleep 600
  fi

done
