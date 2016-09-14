#!/usr/local/bin/bash

# Author: Jamal Shahverdiev
# Script does listing for all csv files, will rename this csv files with normal readable names and uploads them to the Oracle server.

ls /usr/home/ruser/outgoing | while read -r FILE
do
    mv -v "$FILE" `echo $FILE | tr ' ' '_' | tr -d '[{}(),\!]' | tr -d "\'" | tr '[A-Z]' '[a-z]' | sed 's/_-_/_/g'`
done


forls=`ls -l /home/ruser/outgoing/*.csv | awk '{ print $9 }'`
a=`ls -la /usr/home/ruser/outgoing/*.csv | awk '{ print $9 }' | cut -f 2 -d '.' | head -1`

if [ "$a" == csv ]
then
    for i in $forls
    do
        scp $i root@10.10.10.10:/u03/oradata/ABS01/external_dir/cashin_ext_customers.csv
        sleep 5
        ssh root@10.10.10.10 "chown -R oracle:oinstall /u03/oradata/ABS01/external_dir/*.csv"
        cp $i /root/flexibackups
        rm -rf $i             
        ssh root@10.10.10.10 "cd /home/app/oracle/scripts/ext_cust; ./load.sh"
        echo "Upload was successfully for `date +%F.%H:%M:%S` date" >> /home/success-unseccess.log
    done
else
    echo "Upload was unsuccessfully for `date +%F.%H:%M:%S` date" >> /home/success-unseccess.log
    exit                          
fi
