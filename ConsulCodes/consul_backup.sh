#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  consul_backup.sh
# 
#         USAGE:  ./consul_backup.sh 
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
#       CREATED:  08/12/2020 12:18:26 PM +04
#      REVISION:  ---
#===============================================================================

backupDir='/mnt/backup/consul'
backupDate=$(date +%Y/%m/%d)

if [ ! -d $backupDir/$backupDate ]
then
    mkdir -p $backupDir/$backupDate
fi
/usr/local/bin/consul kv export > $backupDir/$backupDate/consul-data.json

