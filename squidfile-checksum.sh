#!/usr/local/bin/bash

# Author: Jamal Shahverdiev
# Script verify checksum for squid.conf file, if there is difference, then it will replace squid.conf file to the original. 

sum=`md5 /usr/local/etc/squid/squid.conf | awk '{ print $4 }'`

if [[ "$sum" != "4036c617b89e105f6eb4e2a1dfccb06f" ]]
then
    cp /root/flashblock.squid.conf /usr/local/etc/squid/squid.conf
    /usr/local/etc/rc.d/squid restart
fi
