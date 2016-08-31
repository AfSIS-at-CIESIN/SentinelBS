#!/bin/bash

export AD2DIR=$1

if [[ -z $AD2DIR ]]; then
  export AD2DIR='/data2/sentinel1/ghana'
fi

export TMPFUL=$AD2DIR/.full.tmp
export TMPPRF=$AD2DIR/.prefix.tmp
export TMPUNQ=$AD2DIR/.unique.tmp

echo "Start Remove Duplicate Products"

dir -1 $AD2DIR | sort > $TMPFUL 
dir -1 $AD2DIR | cut -c -62 > $TMPPRF 

paste $TMPPRF $TMPFUL | sort -k 1 | uniq -w 62 | cut -f2 | sort > $TMPUNQ

for file in `comm -3 $TMPFUL $TMPUNQ`
do
  if [[ -f $AD2DIR/$file ]];then
    echo "Rm "$file
    rm $AD2DIR/$file
  fi
done

echo "Unique files: " `dir -1 $AD2DIR/*.zip | wc -l`
echo "Rm End"

