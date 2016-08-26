#!/bin/bash
# Batch cleaning via sentinenl 1 toolbox
source config.sh

export base=5

divide(){
  n=`echo $1 | grep -o '.dim' | wc -l`
  if [[ n -le $base ]]; then
    echo `merge $1`
  else
    n=`expr $n / $base `

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

    # parallel construction site
    #array=($left $right)
    #for e in ${array[*]}
    #do
    #  echo $e
    #done |
    #(
    #  xargs -n 1 -P 2 -I {} sh -c 'merge ${}'
    #)

    r0=`divide $s0`
    r1=`divide $s1`
    r2=`divide $s2`
    r3=`divide $s3`
    r4=`divide $s4`
    r5=`divide $s5`
    r6=`divide $s6`
    r7=`divide $s7`
    r8=`divide $s8`
    r9=`divide $s9`

    res=$r0','$r1','$r2','$r3','$r4','$r5','$r6','$r7','$r8','$r9
    echo `merge $res`
  fi
}

merge(){
  outname=$RANDOM'.dim'
  $GPT $GRAPH_FOLDER/$MOSAIC -PfileList=$1 -Ptarget=$DIR/$OUTFOLDER/$MOSAIC_FOLDER/$outname -x
  echo $DIR/$OUTFOLDER/$MOSAIC_FOLDER/$outname
}


echo ""
echo "Batch Processing Tool for Sentinel1 Data"
echo "Part II: Merging images"
echo "========================================"

mkdir -p $DIR/$OUTFOLDER
mkdir -p $DIR/$OUTFOLDER/$CALIB_FOLDER
mkdir -p $DIR/$OUTFOLDER/$MOSAIC_FOLDER

export FILELIST=""

for f in $DIR/$OUTFOLDER/$CALIB_FOLDER/*.dim
do
	export FILELIST=${FILELIST}","$f
done

export FILELIST=`echo $FILELIST | cut -c 2-`
echo "FILELIST"
echo $FILELIST | cut -d',' -f 1
echo $FILELIST | grep -o .dim | wc -l

divide $FILELIST

MOSAICNAME=`date +"%Y%m%d%H%M"`"_Mosaic.dim"
RES=`divide $FILELIST`

cp $RES $DIR/$OUTFOLDER/$MOSAICNAME
chmod 777 $DIR/$OUTFOLDER/$MOSAICNAME

echo "Final Mosaic is "$RES
echo "Batch files The end"
