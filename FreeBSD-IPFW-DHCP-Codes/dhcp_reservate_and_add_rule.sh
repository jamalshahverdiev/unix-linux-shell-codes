#!/usr/local/bin/bash

if [ "$#" -lt "2" ]
then
    echo "Script usage: ./$(basename $0) last_octet_of_IPAddress OwnerOfPhone"
    exit 100
fi

IP="172.31.18.$1"
ipOwner="$2"
mac=$(cat /var/log/dhcpd.log | grep $IP | grep -v reuse_lease | grep DHCPACK | awk '{ print $10 }' | tail -n1)

writeInDhcpConf () {
cat <<EOF >> /usr/local/etc/dhcpd.conf
host $ipOwner {
  hardware ethernet $mac;
  fixed-address $IP;
}
EOF
/usr/local/etc/rc.d/isc-dhcpd restart
}

addRuletoIpfw () {
    check=$(cat ./count)
    ipfw add $(($check + 1)) allow ip from any to $IP
    ipfw add $(($check + 2)) allow ip from $IP to any
cat <<EOF >> /etc/ipfw.conf
ipfw add $(($check + 1)) allow ip from any to $IP
ipfw add $(($check + 2)) allow ip from $IP to any
EOF
    echo "$(($check + 2))" > ./count
}

writeInDhcpConf
addRuletoIpfw
