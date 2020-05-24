#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  createFile.sh
# 
#         USAGE:  ./createFile.sh 
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
#       CREATED:  05/24/2020 07:56:36 PM +04
#      REVISION:  ---
#===============================================================================

for count in `seq 2000000`
do
    cat source.txt >> temp.txt
done
