#!/bin/bash

export base=5

divide(){
  n=`echo $1 | grep -o '.dim' | wc -l`
  if [[ n -le $base ]]; then
    echo `merge $1`
  else
    n=`expr $n / $base `

    export res=""

    s0=`echo $1 | cut -d',' -f -$n`
    s1=`echo $1 | cut -d',' -f $((n+1))-$((n*2))`
    s2=`echo $1 | cut -d',' -f $((n*2+1))-$((n*3))`
    s3=`echo $1 | cut -d',' -f $((n*3+1))-$((n*4))`
    s4=`echo $1 | cut -d',' -f $((n*4+1))-`

    # parallel construction site
    inparray=($s0 $s1 $s2 $s3 $s4)
    resarray=("" "" "" "" "")
    for e in {0..5}
    do
      echo $e
    done |
    (
      xargs -P 2 -I{} bash -c '
      echo ${inparray[{}]}
      r=`divide {}`
      export res=$res','$r'
    )
    #r1=`divide $s1`
    #r2=`divide $s2`
    #r3=`divide $s3`
    #r4=`divide $s4`
    #r5=`divide $s5`

    res=`echo $res | cut -c 2-`
    echo `merge $res`
  fi
}

merge(){
  #echo $RANDOM.'dim'
  echo $1
}

export -f divide
export -f merge

string=''
for f in `dir /data2/sentinel1/analysis/calib.tmp/*.dim`
do 
  string=$string','$f
done
string=`echo $string | cut -c 2-`

res=`divide $string`
echo $res
echo `echo $res | grep -o .dim | wc -l`
