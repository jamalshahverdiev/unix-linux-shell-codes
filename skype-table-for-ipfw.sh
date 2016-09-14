#!/bin/sh

# Add Skype IP addresses to the IPFW table

ipfw table 1 flush

cat /root/allskypeips | sort | uniq |  while read ip;
        do ipfw table 1 add $ip
    done
