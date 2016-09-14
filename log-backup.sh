#!/usr/bin/env bash

# Author: Jamal Shahverdiev
# Script will archive log files and then clean them.

sqlogs=`find /var/squid/logs/*.log -type f -size +1G`

for i in $sqlogs
do 
    name=`ls $i | cut -f 5 -d '/'`
    tar -jcf /logdisk/security/squid.`date +%F`.$ad.tar.bz2 $i
    cat '/dev/null' > $i
done


mslogs=`find /var/log/*.log -type f -size +1G`

for a in $mslogs
do
    name=`ls $a | cut -f 5 -d '/'`
    tar -jcf /logdisk/security/allsystem.`date +%F`.$name.tar.bz2 $a
    cat '/dev/null' > $a
done
