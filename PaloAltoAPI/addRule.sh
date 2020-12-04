#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  addRule.sh
# 
#         USAGE:  ./addRule.sh
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
if [ $# != 1 ]
then
    echo "Usage: ./$(basename $0) policyName"
    exit 110
fi

. ./bashlibs/bash-variables.sh
. ./bashlibs/bash-functions.sh

for pname in $existPolicyNames
do
    if [ $pname = $policyNameInput ]
    then
        echo "The name which you tried to create already exists: $pname" 
        echo "If you want to update input the following datas ..."
        readToPreparePostPayload
        putPayload=$(cat $jsonTemplates/dataPost.json | sed "s/ChangeDescription/$description/g;s/ChangeTagMember/$tagMember/g;s/ChangeLogSetting/$logSetting/g;s/ChangeGroupTag/$groupTag/g;s/ChangeRuleName/$policyNameInput/g;s/FromPerimeterName/$FromPerimeterName/g;s/ToPerimeterName/$ToPerimeterName/g;s/applicationName/$applicationName/g;s/destinationPortNumber/$destinationPortNumber/g;s/acceptOrDeny/$acceptOrDeny/g" | sed "s|SourceIPaddress|$SourceIPaddress|g;s|destinationIPaddress|$destinationIPaddress|g")
        echo $putPayload > result.json
        curl -s -k -XPUT -d """$putPayload""" -H "Content-Type: application/json" -H "X-PAN-KEY: $restAPIToken" $securityRulesPath | jq
#    else 
#        readToPreparePostPayload
#        postPayload=$(cat $jsonTemplates/dataPost.json | sed "s/ChangeRuleName/$policyNameInput/g;s/FromPerimeterName/$FromPerimeterName/g;s/ToPerimeterName/$ToPerimeterName/g;s/SourceIPaddress/$SourceIPaddress/g;s/destinationIPaddress/$destinationIPaddress/g;s/applicationName/$applicationName/g;s/destinationPortNumber/$destinationPortNumber/g;s/acceptOrDeny/$acceptOrDeny/g")
#        curl -s -k -XPOST -d """$postPayload""" -H "Content-Type: application/json" -H "X-PAN-KEY: $restAPIToken" $securityRulesPath | jq
#        exit
    fi
done

