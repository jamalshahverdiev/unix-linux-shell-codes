#!/usr/bin/env bash

if [ "$#" -lt 1 ]
then
        echo "Usage: ./$(basename $0) gateName"
        exit 120
fi

if [ "$(dpkg -l | grep jq | grep -v 'lib' | awk '{ print $2 }')" != "jq" ]
then
    echo "Json Query package will be installed."
    apt install -y jq
fi

projectName="sample"
pluginKeyStr='fqm_'
createGateGetId=$(curl -s -u admin:admin -X POST "http://localhost:9000/api/qualitygates/create?name=$1" | jq '.id')
pluginKeys=$(curl -s -u admin:admin -X POST "http://localhost:9000/api/metrics/search" | jq '.metrics | .[].key' | grep $pluginKeyStr | tr -d '"')
searchAllProjects=$(curl -s -u admin:admin "http://localhost:9000/api/projects/search" | jq '.components | .[].name' | tr -d '"')
getProjectID=$(curl -s -u admin:admin "http://localhost:9000/api/projects/search?projects=$projectName" | jq '.components | .[].id' | tr -d '"')

for key in $pluginKeys
do
    curl -s -u admin:admin -X POST "http://localhost:9000/api/qualitygates/create_condition?gateId=$createGateGetId&metric=$key&op=GT&warning=3&error=5" | jq '.'
done

curl -u admin:admin -X POST "http://localhost:9000/api/qualitygates/select?gateId=$createGateGetId&projectId=$getProjectID"


