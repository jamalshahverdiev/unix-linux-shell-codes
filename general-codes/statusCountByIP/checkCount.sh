#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  chechCount.sh
# 
#         USAGE:  ./chechCount.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Jamal Shahverdiev (), jamal.shahverdiev@gmail.com
#       COMPANY:  KapitalBank LLC
#       VERSION:  1.0
#       CREATED:  05/24/2020 07:59:00 PM +04
#      REVISION:  ---
#===============================================================================
echo "Started time: `date +%H:%M:%S`"
input=$(cat source.txt)
echo """$input""" | while read line
do
    ip=$(echo $line | awk '{ print $1 }')
    if [ ! -f $ip.txt ]
    then
        openStateCount=$(echo """$input""" | grep $ip | grep open | wc -l)
        closedStateCount=$(echo """$input""" | grep $ip | grep closed | wc -l)
        echo "Closed state for IP $ip is repeated $closedStateCount times" >> $ip.txt
        echo "Open state for IP $ip is repeated $openStateCount times" >> $ip.txt
    fi
done 
echo "Ended time: `date +%H:%M:%S`"
