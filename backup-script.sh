#!/usr/bin/env bash

month=`date +%m`
year=`date +%Y`
day=`date +%d`
let lastmonth="($month - 1)"

fcount=`date +%m | awk -v FS="" '{print $1}'`
echo $month $lastmonth $fcount

if [[ $fcount == "0" ]]
then
    mkdir "$year-$lastmonth-$day"
    find . -name "2016-0[$lastmonth]*" -exec mv {} $year-$lastmonth-$day \;
    tar jcf $year-$lastmonth-$day"-records.tar.bz2" $year-$lastmonth-$day/*
    if [[ -f `ls *.tar.bz2` ]]
    then
        ftp -in -u ftp://ftp112:F112tp123@10.44.1.100/ `ls *.tar.bz2`
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
    find . -name "2016-$lastmonth*" -exec mv {} $year-$lastmonth-$day \;
    tar jcf $year-$lastmonth-$day"-records.tar.bz2" $year-$lastmonth-$day/*
    if [[ -f `ls *.tar.bz2` ]]
    then
        ftp -in -u ftp://ftp112:F112tp123@10.44.1.100/ `ls *.tar.bz2`
        rm -rf "$year-$lastmonth-$day" `ls *.tar.bz2`
        #mv `ls *.tar.bz2` /tmp
        echo "File is copied to the FTP server" >> /var/log/arciverscript.log
    else
        echo "There is no any tar.bz2 file" >> /var/log/arciverscript.log
        exit 177
    fi
    echo "Month isn't started with zero" >> /var/log/arciverscript.log
else
    exit 172
fi

