#!/usr/local/bin/bash

# Author: Jamal Shahverdiev
# This script was written for delete old video files. 
# If size of file will be more than we have chosen script will delete the file.

fsize=`du -s /var/videos/ | awk '{ print $1 }'`
oldfile=`ls -ltD "%b %C %c" /var/videos/ | tail -n 1 | awk '{ print $13 }'`

if [ $fsize -gt 100000 ]
then
    rm -rf $oldfile
fi
