#!/usr/bin/env bash

ips=`cat ~/iplist`

for ip in $ips
do
    ssh-keyscan -H $ip >> ~/.ssh/known_hosts
done

