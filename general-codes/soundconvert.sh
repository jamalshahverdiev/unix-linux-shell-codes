#!/usr/bin/env bash

# Author: Jamal Shahverdiev
# This script will convert all files with wav extension to the mp3 files.
# I used this script in the FreeSWITCH sevrer.
# Script needs lame convertor. In the FreeBSD you can install: pkg install -y lame

#pforwavs=`ll /root/sondconvert | awk '{ print $9 }'`

for i in *.wav
do
    if [ -e "$i" ]
    then
        file=`echo "$i" | awk 'BEGIN{ FS = "."; OFS=".";} { print $1,$2,$3,$4 }'`
        lame -h -b 192 "$i" "$file.mp3"
    fi
done

