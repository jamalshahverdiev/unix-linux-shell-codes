#!/bin/bash
#===============================================================================
#
#          FILE:  shutdown.sh
# 
#         USAGE:  ./shutdown.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Jamal Shahverdiev (), jamal.shahverdiev@gmail.com
#       COMPANY:  Open Source Corporation
#       VERSION:  1.0
#       CREATED:  07/26/17 19:11:04 AZT
#      REVISION:  ---
#===============================================================================

iplist=$(cat iplist)

for i in $iplist
do
    ssh $i "init 0"
done
