#/usr/bin/env bash

# Author: Jamal Shahverdiev
# Script reads /root/hosts file and gets all IP addresses for DNS names in this file.
# Same principle for "nslookup" and "dig"

while read -r line
do
    nslookup $line | grep -v 53 | grep Address | awk '{ print $2}' >> ips.txt
done < /root/hosts

hostlar=`cat /root/hosts`
for i in $hostlar
do
    dig $i | grep $i | grep -v ";" >> /root/ips-from-dig
done
