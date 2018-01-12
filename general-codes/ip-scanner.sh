#!/usr/bin/env bash

# Author: Jamal Shahverdiev
# This script scans network for "net" variable.
# If you want to skan network for 24 bit range, just change this subnet.

net='172.16.100.'

check_ping() {
    ping -c 1 $1 > /dev/null
    if [ $? -eq 0 ]
    then
        echo Host: $i is up.
    else
        exit
    fi
}

for i in "$net"{1..254}
do
    # "disown" prevents process to go to the job list. It means you cannot get job id via 'jobs -l'
    check_ping $i & disown
done
