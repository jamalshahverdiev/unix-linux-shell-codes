#!/usr/local/bin/bash

# Author: Jamal Shahverdiev
# This script will scan network from "net" variable. 
# You can set IP range into curly brackets. 

net=172.16.100

for i in $net.{1..200}
do 
    losted=`ping -W 0.0001 -c 1 $i | tail -n 1 | awk '{ print $7 }'`
    isupstat=`ping -W 0.0001 -c 1 $i | tail -n 2 | grep -v round-trip | awk '{ print $7 }'`
    if [[ $losted = "100.0%" ]]
    then
        echo $i host is DOWN.
    elif [[ $isupstat = "0.0%" ]]
    then
        echo $i host is UP.
    fi
done
