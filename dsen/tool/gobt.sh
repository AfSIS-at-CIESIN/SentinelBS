#!/bin/bash

xmlfile="./output/search_result.xml"
outfile="./filtered.txt"

#for obt in `cat $xmlfile | grep '"relativeorbitnumber.*' | cut -f2 -d'>' | cut -f1 -d'<' | sort | uniq`
#do 
#  mkdir -p "./output/"$obt
#done

cat $xmlfile | grep -o '"identifier.*' | cut -f2 -d'>' | cut -f1 -d'<' > .name.tmp
cat $xmlfile | grep '"relativeorbitnumber.*' | cut -f2 -d'>' | cut -f1 -d'<' > .obt.tmp
paste -d',' .obt.tmp .name.tmp > .combined.tmp

rm .name.tmp
rm .obt.tmp

for line in `cat .combined.tmp`
do
  orbt=`echo $line | cut -f1 -d','`
  name=`echo $line | cut -f2 -d','`
  if [[ -d "./output/"$orbt ]]; then
    echo '' > "./output/"$orbt"/"$name
  fi
done

rm .combined.tmp
