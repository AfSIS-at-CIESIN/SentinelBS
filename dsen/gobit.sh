#!/bin/bash

xmlfile="./output/search_result.xml"

#for obt in `cat $xmlfile | grep '"relativeorbitnumber.*' | cut -f2 -d'>' | cut -f1 -d'<' | sort | uniq`
#do 
#  mkdir -p "./output/"$obt
#done

for line in `cat $xmlfile`
do
  name=`echo $line | grep -o '<title>.*</title>' | cut -f2 -d'>' | cut -f1 -d'<'`
  robt=`echo $line | grep '"relativeorbitnumber.*' | cut -f2 -d'>' | cut -f1 -d'<'`
  if [[ -d './output/'$robt ]]; then
    echo '' > './output/'$robt'/'$name
  fi
done

