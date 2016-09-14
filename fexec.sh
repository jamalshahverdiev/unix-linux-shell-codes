#!/usr/bin/env bash

# Author: Jamal Shahverdiev
# This script was written for the FreeSWITCH server.
# Script creates backup folder for recorded voice files to last month and move them to this folder.
# After that script upload archived file to the FTP sevrer.

month=`date +%m`
year=`date +%Y`
day=`date +%d`
let lastmonth="($month - 1)"

fcount=`date +%m | awk -v FS="" '{print $1}'`
echo $month $lastmonth $fcount

if [[ $fcount == "0" ]]
then
    mkdir "$year-$lastmonth-$day"
    find . -name -type f "2016-0[$lastmonth]*" -exec mv {} $year-$lastmonth-$day \;
    tar jcf $year-$lastmonth-$day"-records.tar.bz2" $year-$lastmonth-$day/*
    if [[ -f `ls *.tar.bz2` ]]
    then
        ftp -in -u ftp://ftpuser:ftppass@10.100.100.100/ `ls *.tar.bz2`
        # curl -T `ls *.tar.bz2` ftp://10.100.100.100  --user ftpuser:ftppass
        rm -rf "$year-$lastmonth-$day" `ls *.tar.bz2`
        echo "File is copied to the FTP server" >> /var/log/arciverscript.log
    else
        echo "There is no any tar.bz2 file" >> /var/log/arciverscript.log
        exit 177
    fi
    echo "Month started with zero" >> /var/log/arciverscript.log
else
    exit 172
fi

if [[ $fcount != "0" ]]
then
    mkdir "$year-$lastmonth-$day"
    find . -name -type f "2016-$lastmonth*" -exec mv {} $year-$lastmonth-$day \;
    tar jcf $year-$lastmonth-$day"-records.tar.bz2" $year-$lastmonth-$day/*
    if [[ -f `ls *.tar.bz2` ]]
    then
        ftp -in -u ftp://ftpuser:ftppass@10.100.100.100/ `ls *.tar.bz2`
        # curl -T `ls *.tar.bz2` ftp://10.100.100.100  --user ftpuser:ftppass
        rm -rf "$year-$lastmonth-$day" `ls *.tar.bz2`
        echo "File is copied to the FTP server" >> /var/log/arciverscript.log
    else
        echo "There is no any tar.bz2 file" >> /var/log/arciverscript.log
        exit 177
    fi
    echo "Month isn't started with zero" >> /var/log/arciverscript.log
else
    exit 172
fi
