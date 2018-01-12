#!/usr/bin/env bash

# Author: Jamal Shahverdiev
# Script will check gateway IP addresses and if one fail,
# it will automatically forward traffic to the other default gateway.

def='192.168.11.1'
alt='10.10.10.10'
dcheck=`ping -W2 -c 1 $def | grep ttl | awk '{ print $6 }' | cut -f 1 -d '='`
acheck=`ping -W2 -c 1 $alt | grep ttl | awk '{ print $6 }' | cut -f 1 -d '='`

if [ "$dcheck" == "ttl" ] && [ "$acheck" == "ttl" ]
then
    echo "Boths are UP."
    exit 0
elif [ "$dcheck" == "ttl" ] && [ "$acheck" != "ttl" ]
then	
    echo "Alternate gateway is not working."
    route delete default
    route add default $def
    exit 0
elif [ "$dcheck" != "ttl" ] && [ "$acheck" == "ttl" ]
then
    route delete default
    route add default $alt
    echo "Added secondary default route because, primary is not works."
fi

# Add the following lines to the /etc/crontab file. 
# This lines will execure this script every 10 seconds. 
#* * * * * /usr/local/bin/bash /root/multigateways.sh
#* * * * * sleep 10; /usr/local/bin/bash /root/multigateways.sh
#* * * * * sleep 20; /usr/local/bin/bash /root/multigateways.sh
#* * * * * sleep 30; /usr/local/bin/bash /root/multigateways.sh
#* * * * * sleep 40; /usr/local/bin/bash /root/multigateways.sh
#* * * * * sleep 50; /usr/local/bin/bash /root/multigateways.s
