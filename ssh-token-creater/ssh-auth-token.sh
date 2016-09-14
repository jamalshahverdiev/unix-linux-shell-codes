#!/usr/bin/env bash

# Author: Jamal Shahverdiev
# This script will read IP address list from "iplist" file. 
# Script will generate one key pair per adress from "iplist" file. 
# Then will configure SSH token authentication between all this IP adresses.

# Script needs "sshpass". Please install "sshpass" with the following commands:
# FreeBSD: pkg install -y sshpass
# CentOS: yum install -y epel-release ; yum install -y sshpass
# Ubuntu: apt-get install sshpass


iplist=$(cat iplist)

credentials () {
    read -p "Please enter username of the remote server: " user
    read -sp "Please enter password for the $user user: " pass
    echo
}

credentials

for ip in $iplist
do
    ssh-keyscan -H $ip >> ~/.ssh/known_hosts
    hname=$(sshpass -p "$pass" ssh $user@$ip "hostname") 2> /dev/null
    $(sshpass -p "$pass" ssh $user@$ip "mkdir ~/.ssh ; cd ~/.ssh/ ; ssh-keygen -f id_rsa -t rsa -N ''") 2> /dev/null
    $(sshpass -p "$pass" scp $user@$ip:"~/.ssh/id_rsa.pub" ./$hname.id_rsa.pub) 2> /dev/null
done

$(cat `pwd`/*.pub >> authorized_keys)

for ip in $iplist
do
    $(sshpass -p "$pass" scp -r ~/.ssh/known_hosts authorized_keys root@$ip:"~/.ssh/") 2> /dev/null
done
