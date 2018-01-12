#!/bin/sh

# Author: Jamal Shahverdiev
# Script blocks users connection to the Skype vi IPFW firewall table.

a=`cat /root/blocked_users_to_skype`

for i in $a
        do 
                ipfw add 64000 deny all from $i to table\(1\)
        done
