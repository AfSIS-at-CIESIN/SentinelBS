#!/bin/bash

export AD2DIR=$1
if [[ -z $AD2DIR ]];then
  export AD2DIR='/data2/sentinel1/ghana'
fi
LOG=$AD2DIR/"rmred.log"

dates=("20160102T" "20160104T" "20160111T" "20160123T" "20160128T" "20160204T" "20160209T" "20160216T" "20160228T" "20160304T" "20160311T" "20160316T" "20160323T" "20160328T" "20160331T")

echo "Start rm from "`ls -1 $AD2DIR/*.zip | wc -l`" files"
echo "" > $LOG

for date in ${dates[*]}
do
  for file in `ls -1 $AD2DIR | grep $date`
  do
    echo "Removing "$file
    echo "Removing "$file >> $LOG
    rm $AD2DIR/$file
  done
done

echo "Left with "`ls -1 $AD2DIR/*.zip | wc -l`" files"
