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
echo "Stared time: `date +%H:%M:%S`"
declare -A iparray
input=$(cat source.txt)
echo """$input""" | { while read line
    do
        if [[ ! -v iparray[$line] ]]
        then
            iparray+=([$line]=${iparray[$line]=1})
        else
            iparray+=([$line]=`expr ${iparray[$line]} + 1`)
        fi
    done 

    for result in "${!iparray[@]}"
    do
        echo "Array key: $result, Array value: ${iparray[$result]}" >> retice.txt
    done
}

echo "Ended time: `date +%H:%M:%S`"

