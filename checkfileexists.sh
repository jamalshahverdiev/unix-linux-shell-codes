#!/usr/bin/env bash

# Author: Jamal Shahverdiev
# Script check file existing from source folder to the destination folder.
# If file exists on the destination folder it will inform about this. 
# If file is not exists on the destination folder it will copy this file to there.

src='/root/videos'
dest='/usr/local/www/datam.com'
dfiles="ls /usr/local/www/datam.com"
sfiles=`ls /root/videos`
for l in $sfiles
 do
  a=`$dfiles | grep $l`
  if [[ $a == $l ]]
     then
     echo "$l file is exists in the public_html folder!!!"
  else
     cp $src/$l $dest
     echo "File is already copied!"
  fi
done
