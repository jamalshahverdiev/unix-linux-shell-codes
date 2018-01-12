#!/usr/bin/env bash

# Author: Jamal Shahverdiev
# This script does backup for xml files which, came from SFTP "post" user.
# Script will copy backup files to the different NFS servers.

ls /home/post/post | while read -r FILE
do
    mv -v "$FILE" `echo $FILE | tr ' ' '_' | tr -d '[{}(),\!]' | tr -d "\'" | tr '[A-Z]' '[a-z]' | sed 's/_-_/_/g'`
done

path="/home/post/post/"
var=$(ls -la /home/post/post/ | awk 'BEGIN { FS = "." } ; { print $2 }')

if [[ "$var" == *xml* ]]
then
    cp /home/post/post/*.xml /shares/data
    cp /home/post/post/*.xml /sftphome/foxmls
    sleep 2
    rm -rf /home/post/post/*.xml
    echo "`date +%F.%H:%M` date all XML files was successfully handled in the $path folder" >> /home/file
else
    echo "No files or folders has been uploaded into $path folder at `date +%F.%H:%M` date" >> /home/faylreport
fi
