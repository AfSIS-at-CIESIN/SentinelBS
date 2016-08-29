#!/bin/bash

export base=5

mosaic() {
  #echo $1
  n=`echo $1 | grep -o .dim | wc -l`
  echo "" > $2/$n".out"
}

merge(){
  #echo $RANDOM.'dim'
  res=0
  for d in `find $1 -maxdepth 1 -mindepth 1 -type d`
  do
    n=$(basename $(find $d -maxdepth 1 -type f) | cut -d'.' -f 1)
    res=`expr $res + $n`
  done

  echo "" > $1/$res".out"
}

divide(){
  n=`echo $1 | grep -o '.dim' | wc -l`
  if [[ n -le $base ]]; then
    mosaic $1 $2
  else
    n=`expr $n / $base + 1`

    s0=`echo $1 | cut -d',' -f -$n`
    s1=`echo $1 | cut -d',' -f $((n+1))-$((n*2))`
    s2=`echo $1 | cut -d',' -f $((n*2+1))-$((n*3))`
    s3=`echo $1 | cut -d',' -f $((n*3+1))-$((n*4))`
    s4=`echo $1 | cut -d',' -f $((n*4+1))-`

    # parallel construction site
    inparray=($s0 $s1 $s2 $s3 $s4)
    resarray=("" "" "" "" "")
    for (( e=0; e<$base; e++ ))
    do
      mkdir -p $2/$e
      echo ${inparray[$e]} $2/$e
    done |
    (
      xargs -P 2 -n 2 -I{} bash -c '
      divide {}'
    )

    merge $2
  fi
}

export -f divide
export -f merge
export -f mosaic

#string=''
#for f in `dir /data2/sentinel1/analysis/calib.tmp/*.dim`
#do 
#  string=$string','$f
#done
#string=`echo $string | cut -c 2-`
string='1.dim,2.dim'

divide $string ./test
echo $res
echo `echo $res | grep -o .dim | wc -l`
