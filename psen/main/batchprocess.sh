#!/bin/bash
# Batch cleaning via sentinenl 1 toolbox

export CONFIG=$1
if [[ -z $CONFIG ]];then
  echo "Using Default Config File"
  export CONFIG=`dirname $0`'/../config/config.sh'
fi
source $CONFIG

export base=10

mosaic(){
  outname=$2/$RANDOM'.dim'
  $GPT $GRAPH_FOLDER/$MOSAIC -PfileList=$1 -Ptarget=$outname
}

merge(){
  children=''
  for d in `find $1 -maxdepth 1 -type f`
  do
    child=$(basename $(find $d -maxdepth 1 -type f) | cut -d'.' -f 1)
    children=$children','$child
  done
  children=`echo $children | cut -c 2-`

  mosaic $children $1
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
    s4=`echo $1 | cut -d',' -f $((n*4+1))-$((n*5))`
    s5=`echo $1 | cut -d',' -f $((n*5+1))-$((n*6))`
    s6=`echo $1 | cut -d',' -f $((n*6+1))-$((n*7))`
    s7=`echo $1 | cut -d',' -f $((n*7+1))-$((n*8))`
    s8=`echo $1 | cut -d',' -f $((n*8+1))-$((n*9))`
    s9=`echo $1 | cut -d',' -f $((n*9+1))-`

    # parallel
    array=($s0 $s1 $s2 $s3 $s4 $s4 $s6 $s7 $s8 $s9)
    for (( e=0; e<$base; e++ ))
    do
      mkdir -p $2/$e
      echo ${array[$e]} $2/$e
    done |
    (
      xargs -n 1 -P 2 -n 2 -I {} bash -c 'divide {}'
    )

    merge $2

  fi
}

export -f divide
export -f merge
export -f mosaic

echo ""
echo "Batch Processing Tool for Sentinel1 Data"
echo "Part II: Merging images"
echo "========================================"

export FILELIST=""

for f in `dir $DIR/$OUTFOLDER/$CALIB_FOLDER/*.dim*` 
do
	export FILELIST=${FILELIST}","$f
done

export FILELIST=`echo $FILELIST | cut -c 2-`
echo "# FILES"
echo $FILELIST | grep -o .dim | wc -l

#MOSAICNAME=`date +"%Y%m%d%H%M"`"_Mosaic"
mkdir -p $DIR/$OUTFOLDER
mkdir -p $DIR/$OUTFOLDER/$MOSAIC_FOLDER
#mkdir -p $DIR/$OUTFOLDER/$MOSAICNAME

#divide $FILELIST $DIR/$OUTFOLDER/$MOSAICNAME
mosaic $FILELIST $DIR/$OUTFOLDER/$MOSAIC_FOLDER

chmod -R 777 $DIR/$OUTFOLDER/$MOSAIC_FOLDER

echo "Batch files The end"

