#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  checkPorts.sh
#
#         USAGE:  ./checkPorts.sh
#
#   DESCRIPTION:
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Jamal Shahverdiev (), jamal.shahverdiev@gmail.com
#       COMPANY:  Pronet LLC
#       VERSION:  1.0
#       CREATED:  12/18/2019 09:03:15 AM CET
#      REVISION:  ---
#===============================================================================

ips='
178.238.233.82
79.143.186.145
79.143.186.175
80.241.222.142
79.143.190.121
178.238.237.79
79.143.190.3
178.238.233.93
178.238.234.150
178.238.234.99
'

consulPorts='
8300
8301
8302
8500
8600
'

etcdPorts='
5432
8008
2379
2380
'

rabbitPorts='
4369
5000
25672
5672
7000
'

for ip in $ips
do
    for port in $rabbitPorts
    do
       nc -zvw3 $ip $port 2>&1 | grep Connected
    done
done
