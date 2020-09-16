#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  create_vaultPolicy.sh
# 
#         USAGE:  ./create_vaultPolicy.sh 
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
#       CREATED:  04/06/2020 12:39:56 PM +04
#      REVISION:  ---
#===============================================================================


deployments='
create
services
list
'

for pod in $deployments
do
    echo \"secret/data/atlas/$pod\":\{\"capabilities\":[\"create\",\"read\",\"list\",\"update\",\"delete\"]\},
    echo \"secret/data/atlas/$pod/prod\":\{\"capabilities\":[\"create\",\"read\",\"list\",\"update\",\"delete\"]\},
done
