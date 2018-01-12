#!/usr/bin/env bash

# Author: Jamal Shahverdiev
# Script needs SSH token authentication between Linux desktop and WEB server. 
# Script wait input for web server IP and file name for upload to the Virtual host PUBLIC_HTML folder.


read -p 'Please enter IP address for the web server: ' IP
read -p 'Please enter file which you want to upload to the web server: ' fname

copy="scp $fname root@$IP:/var/www/linux.az/html/"
checkfile=`ssh root@$IP "ls /var/www/linux.az/html/ | grep $fname"`

if [[ $checkfile == $fname ]]
then
    echo
    echo " $fname file is already exists in the web server!!!"
    echo " Please check file and execute ./`basename $0` script again. "
    echo " Otherwise file will be overwritten..."
    echo
else
    `$copy`
    checkfagain=`ssh root@$IP "ls /var/www/linux.az/html/ | grep $fname"`
    if [[ $fname == $checkfagain ]]
    then
        echo "$fname file is successfully copied to the web server!!!"
        exit 0
    else
        echo "Happened error while copying file."
        exit 177
    fi
fi
