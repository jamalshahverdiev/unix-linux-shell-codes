#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  bash-functions.sh
# 
#         USAGE:  ./bash-functions.sh 
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
#       CREATED:  05/28/2020 02:26:56 PM +04
#      REVISION:  ---
#===============================================================================

servicesAPIEndpoint() {
    serviceNamePort=$1
    serviceObjects=$2
    createServicePath="https://$deviceIP/$restAPI/$serviceObjects?name=$serviceNamePort&location=vsys&vsys=vsys1"
}

createService() {
    servicesAPIEndpoint $1 $2 
    port=$(echo $serviceNamePort | cut -f1 -d'_')
    protocol=$(echo $serviceNamePort | cut -f2 -d'_' | tr '[A-Z]' '[a-z]')
    servicePOSTJsonData=$(cat $jsonTemplates/postServiceTemplate.json)
    servicePOSTPayload=$(echo $servicePOSTJsonData| sed "s/serviceNamePort/$serviceNamePort/g;s/changeProtocol/$protocol/g;s/changePort/$port/g")
    curl -i -s -k -XPOST -d """$servicePOSTPayload""" -H "Content-Type: application/json" -H "X-PAN-KEY: $restAPIToken" $createServicePath
}

readToPreparePostPayload(){
    read -p "Please input source zone name: " FromPerimeterName
    read -p "Please input destination zone name: " ToPerimeterName
    read -p "Please input source IP address: " SourceIPaddress
    read -p "Please input destination IP address: " destinationIPaddress
    read -p "Please input application name: " applicationName
    read -p "Please input destination port number(It must be like as 80_TCP or 53_UDP): " destinationPortNumber
    read -p "Please input allow or deny rule (Example allow, deny): " acceptOrDeny

        if [[ $existServicesINCurrentPolicy =~ .*$destinationPortNumber* || -z "$destinationPortNumber" ]]
        then
            echo "Entered service name is already exists or empty. Will use existing values: $destinationPortNumber"
            destinationPortNumber=$(echo $jsonData | jq '.result.entry | .[].service.member' | tr -d '[]\n  ' | sed 's/^.//;s/.$//')
        elif [[ $jsonDataServices =~ .*$destinationPortNumber* ]]
        then
            echo "Entered service name: $destinationPortNumber"
            destinationPortNumber=$(echo $jsonData | jq '.result.entry | .[].service.member' | jq '. + [ "'$destinationPortNumber'" ]' | tr -d '[]\n  ' | sed 's/^.//;s/.$//')
        else
            echo "Entered Service name not exists in global service list. We will create it automatically."
            createService $destinationPortNumber $serviceObjects
        fi

        if [[ $existSourceINCurrentPolicy =~ .*$FromPerimeterName* || -z "$FromPerimeterName" ]]
        then
            echo Entered source zone name is already exists or empty. Will use existing values: $FromPerimeterName
            FromPerimeterName=$(echo $jsonData | jq '.result.entry | .[].from.member' | tr -d '[]\n  ' | sed 's/^.//;s/.$//')
        elif [[ $existZoneNames =~ .*$FromPerimeterName* ]]
        then
            echo "Entered source zone name: $destinationPortNumber"
            FromPerimeterName=$(echo $jsonData | jq '.result.entry | .[].from.member' | jq '. + [ "'$FromPerimeterName'" ]' | tr -d '[]\n  ' | sed 's/^.//;s/.$//')
        else
            echo "Entered source Perimeter name doesn't exists. Please double check name and try again."
            exit 404
        fi

        if [[ $existDestinationINCurrentPolicy =~ .*$ToPerimeterName* || -z "$ToPerimeterName" ]]
        then
            echo Entered destination zone name is already exists or empty. Will use existing values: $ToPerimeterName
            ToPerimeterName=$(echo $jsonData | jq '.result.entry | .[].to.member' | tr -d '[]\n  ' | sed 's/^.//;s/.$//')
        elif [[ $existZoneNames =~ .*$ToPerimeterName* ]]
        then
            ToPerimeterName=$(echo $jsonData | jq '.result.entry | .[].to.member' | jq '. + [ "'$ToPerimeterName'" ]' | tr -d '[]\n  ' | sed 's/^.//;s/.$//')
        else
            echo "Entered destination Perimeter name doesn't exists. Please double check name and try again."
            exit 404
        fi

        if [[ ! -z "$acceptOrDeny" && ($acceptOrDeny = 'allow' || $acceptOrDeny = 'deny') ]]
        then
            echo "Empty input will use default action of rule or you can type only 'allow/deny' to apply action"
            acceptOrDeny=$acceptOrDeny
        else
            acceptOrDeny=$(echo $jsonData | jq -r '.result.entry | .[].action')
        fi

        if [[ $sourceIPs =~ .*$SourceIPaddress* || -z "$SourceIPaddress" ]]
        then
            echo "Entered source IP address empty or already exist in the rule source content or empty. Will use existing values:: $SourceIPaddress"
            SourceIPaddress=$(echo $jsonData | jq '.result.entry | .[].source.member' | tr -d '[]\n  ' | sed 's/^.//;s/.$//')
        else
            SourceIPaddress=$(echo $jsonData | jq '.result.entry | .[].source.member' | jq '. + [ "'$SourceIPaddress'" ]' | tr -d '[]\n  ' | sed 's/^.//;s/.$//')
        fi

        if [[ $destinationIPs =~ .*$destinationIPaddress* || -z "$destinationIPaddress" ]]
        then
            echo "Entered destination IP address empty or already exist in the rule source content or empty. Will use existing values: $destinationIPaddress"
            destinationIPaddress=$(echo $jsonData | jq '.result.entry | .[].destination.member' | tr -d '[]\n  ' | sed 's/^.//;s/.$//')
        else
            destinationIPaddress=$(echo $jsonData | jq '.result.entry | .[].destination.member' | jq '. + [ "'$destinationIPaddress'" ]' | tr -d '[]\n  ' | sed 's/^.//;s/.$//')
        fi

        if [[ -z "$applicationName" ]]
        then
            echo "Entered application name empty. Will use existing values: $applicationName"
            applicationName=$(echo $jsonData | jq '.result.entry | .[].application.member' | tr -d '[]\n  ' | sed 's/^.//;s/.$//')
        else
            applicationName=$applicationName
        fi
}

deleteService() {
    servicesAPIEndpoint $1 $2
    curl -i -s -k -XDELETE -H "X-PAN-KEY: $restAPIToken" $createServicePath
}

