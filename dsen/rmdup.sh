#!/bin/bash

export AD2DIR='/data2/sentinel1/ghana'
export OUTDIR='./test'

export TMPFUL=$OUTDIR/.full.tmp
export TMPPRF=$OUTDIR/.prefix.tmp
export TMPUNQ=$OUTDIR/.unique.tmp

echo "Start Remove Duplicate Products"

mkdir -p $OUTDIR

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

echo "Unique files: " `dir -1 $AD2DIR | wc -l`
echo "Rm End"

