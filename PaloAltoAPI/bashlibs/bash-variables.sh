#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  bash-variables.sh
# 
#         USAGE:  ./bash-variables.sh 
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
#       CREATED:  05/28/2020 04:58:43 PM +04
#      REVISION:  ---
#===============================================================================

policyNameInput=$1
restAPIToken=''
deviceIP='10.1.1.10'
restAPI='restapi/9.0'
policyRules='Policies/SecurityRules'
serviceObjects='Objects/Services'
networkZones='network/zones'
jsonTemplates='jsonTemps'
securityRulesPath="https://$deviceIP/$restAPI/$policyRules?name=$policyNameInput&location=vsys&vsys=vsys1"
serviceListPath="https://$deviceIP/$restAPI/$serviceObjects?location=vsys&vsys=vsys1"
networkZonesPath="https://$deviceIP/$restAPI/$networkZones?location=vsys&vsys=vsys1"
jsonData=$(curl -s -k -XGET -H "X-PAN-KEY: $restAPIToken" $securityRulesPath)
jsonDataServices=$(curl -s -k -XGET -H "X-PAN-KEY: $restAPIToken" $serviceListPath | jq '.result.entry | .[]."@name"')
getCountOfServices=$(echo $jsonDataServices | sed 's/ /\n/g' | wc -l)
RulesPath="https://$deviceIP/$restAPI/Policies/SecurityRules?location=vsys&vsys=vsys1"
allSecurityRulesPath="https://$deviceIP/$restAPI/$policyRules?location=vsys&vsys=vsys1"
getCountOfNames=$(curl -s -k -XGET -H "X-PAN-KEY: $restAPIToken" $allSecurityRulesPath | jq '.result.entry | .[]."@name"' | wc -l)
securityRulesJsonData=$(curl -s -k -XGET -H "X-PAN-KEY: $restAPIToken" $allSecurityRulesPath)
arraycount=`expr $getCountOfNames - 1`
existPolicyNames=$(curl -s -k -XGET -H "X-PAN-KEY: $restAPIToken" $RulesPath | jq '.result.entry | .[]."@name"' | tr -d '"')
existZoneNames=$(curl -s -k -XGET -H "X-PAN-KEY: $restAPIToken" $networkZonesPath | jq '.result.entry | .[]."@name"')
sourceIPs=$(echo $jsonData| jq -r '.result.entry | .[].source.member' | jq '.[]')
destinationIPs=$(echo $jsonData| jq -r '.result.entry | .[].destination.member | .[]')
existServicesINCurrentPolicy=$(echo $jsonData| jq -r '.result.entry | .[].service.member | .[]')
existSourceINCurrentPolicy=$(echo $jsonData| jq -r '.result.entry | .[].from.member | .[]')
existDestinationINCurrentPolicy=$(echo $jsonData| jq -r '.result.entry | .[].to.member | .[]')
acceptOrDeny=$(echo $jsonData | jq -r '.result.entry | .[].action')
description=$(echo $jsonData | jq -r '.result.entry | .[].description')
tagMember=$(echo $jsonData | jq -r '.result.entry | .[].tag.member | .[]')
logSetting=$(echo $jsonData | jq -r '.result.entry | .[]."log-setting"')
groupTag=$(echo $jsonData | jq -r '.result.entry | .[]."group-tag"')

