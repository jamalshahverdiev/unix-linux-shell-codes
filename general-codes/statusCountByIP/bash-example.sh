#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  bash-example.sh
# 
#         USAGE:  ./bash-example.sh 
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
#       CREATED:  04/13/2021 12:12:15 AM +04
#      REVISION:  ---
#===============================================================================

cat source.txt | awk '{print $1,$2}' | sort -n | uniq -c
