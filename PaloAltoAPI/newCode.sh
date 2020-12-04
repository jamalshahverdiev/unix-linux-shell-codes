#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  newCode.sh
# 
#         USAGE:  ./newCode.sh 
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
#       CREATED:  05/26/20 11:40:32 +04
#      REVISION:  ---
#===============================================================================
if [ $# != 2 ]
then
    echo "Usage: ./$(basename $0) destinationIP portNumber"
    exit 110
fi

destinationIP=$1
portNumber=$2

. ./bashlibs/bash-variables.sh

for count in `seq 0 $arraycount`
do 
    policyName=$(echo $securityRulesJsonData | jq -r '.result.entry | .['$count']."@name"')
    destMember=$(echo $securityRulesJsonData | jq -r '.result.entry | .['$count'].destination.member')
    serviceMember=$(echo $securityRulesJsonData | jq -r '.result.entry | .['$count'].service.member')
    if [[ $destMember =~ .*$destinationIP* && $serviceMember =~ $portNumber ]]
    then
        echo Policy name is: $policyName
        echo Destination member is: $destMember
        echo Service list is: $serviceMember
        echo 
    fi
done

echo '************************************************************************************************'
echo "If you want to add new rule please use ./addRule.sh script"
echo "If you want to modify one of the existing rules, choose the name and use ./modifyRule.sh script"
echo "If you want add new policy, please use ./addPolicy.sh script"

