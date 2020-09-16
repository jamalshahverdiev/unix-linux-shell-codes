#!/usr/bin/env bash

MESSAGE='Hamiya Salam Olsun'
#COLOR='#CC4A31'
COLOR='#6264A7'
TITLE='PostToTeams'
JSON="{\"title\": \"${TITLE}\", \"themeColor\": \"${COLOR}\", \"text\": \"${MESSAGE}\" }"
WEBHOOK_URL=''

curl -H 'Content-Type: application/json' -d "${JSON}" -XPOST $WEBHOOK_URL
