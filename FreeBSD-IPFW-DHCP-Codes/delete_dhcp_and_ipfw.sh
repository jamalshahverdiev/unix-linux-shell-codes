#!/usr/local/bin/bash

if [ "$#" -lt "1" ]
then
    echo "Script usage: ./$(basename $0) OwnerOfPhone"
    exit 100
fi

dhcpconffile="/usr/local/etc/dhcpd.conf"
ipfwconffile="/etc/ipfw.conf"
dhcpfirstline=$(cat -n ${dhcpconffile} | grep -i $1 | awk '{ print $1 }')
dhcplastline=$(($dhcpfirstline + 3))
ipnum=$(($dhcpfirstline + 2))
ipAddr=$(cat -n $dhcpconffile | grep "^    $ipnum" | awk '{ print $3 }' | tr -d ';')
ipfwrulelist=$(cat $ipfwconffile | grep $ipAddr | awk '{ print $3 }')
ipfwnums=$(cat -n $ipfwconffile | grep $ipAddr | awk '{ print $1 }')
#echo $dhcpfirstline $dhcplastline $ipnum $ipAddr $ipfwrulelist $ipfwnums

deleteInDhcpConf () {
    sed -i -e'' "${dhcpfirstline},${dhcplastline}d" $dhcpconffile
    /usr/local/etc/rc.d/isc-dhcpd restart
}

deleteInIpfwConf () {
    for ip in $ipfwrulelist
    do
        ipfw delete $ip
    done
    for num in $ipfwnums
    do
        sed -i -e'' "${num}d" $ipfwconffile
    done
}

deleteInDhcpConf
deleteInIpfwConf

