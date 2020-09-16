#!/usr/bin/env bash

bucketName=progitlab-backup
filenames=$(aws s3 ls $bucketName | awk '{ print $NF}')
yesterday=$(date +%Y_%m_%d -d "1 day ago")
today=$(date +%Y_%m_%d)

for file in $filenames
do
     fileDate=$(aws s3 ls $bucketName/$file | awk '{ print $NF}' | cut -f1 -d'.' | awk -F'_' 'BEGIN{OFS="_";} { print $2,$3,$4 }')
     if [ $fileDate = $yesterday -o $fileDate = $today ]
     then
         echo "File $file for the $fileDate date will be stored in the AWS bucket!"
     else
         echo "File $file for the $fileDate date will be deleted from AWS bucket!"
         aws s3 rm s3://$bucketName/$file
     fi
done

