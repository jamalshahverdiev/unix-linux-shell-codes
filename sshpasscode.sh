#!/usr/bin/env bash

# Author: Jamal Shahverdiev
# Script read input from "ipaddresses" file for remote server IP,password and command for execute in the remote server.

# For use "sshpass" we must install this as follows:
# pkg install -y sshpass

read -p "Please enter password for servers: " pass
read -p "Please enter command for servers: " comm

ips=`cat /root/bash-codes/ipaddresses`

for IP in $ips
do
    sshpass -p "$pass" ssh root@$IP "$comm"
    echo "========================================================================"
done
