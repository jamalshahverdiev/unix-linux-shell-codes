#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  writedata.sh
# 
#         USAGE:  ./writedata.sh 
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
#       CREATED:  03/19/2020 11:11:58 AM +04
#      REVISION:  ---
#===============================================================================


serviceNames='ms-identity'

getProdToken=$(curl -s --request POST --data '{"role_id": "", "secret_id": ""}' http://192.168.9.222:8200/v1/auth/approle/login | jq -r .auth.client_token)
#getPreToken=$(curl -s --request POST --data '{"role_id": "", "secret_id": ""}' http://192.168.9.222:8200/v1/auth/approle/login | jq -r .auth.client_token)
#getDevToken=$(curl -s --request POST --data '{"role_id": "", "secret_id": ""}' http://192.168.9.222:8200/v1/auth/approle/login | jq -r .auth.client_token)

#getData=$(curl -s -X GET -H "X-Vault-Token:7e37e506-66ce-a77d-eaec-030ca4cbb0b0" 'http://192.168.9.222:8200/v1/secret/data/atlas/ms-claim/prod?version=1' | jq -r .data.data)
#vault login $getDevToken
vault login $getProdToken
#vault login $getPreToken
for service in $serviceNames
do
    #vault kv put secret/prjname/$service/preprod @ms-identity-pre.json
    vault kv put secret/prjname/$service/prod @ms-identity-prod.json
    #vault kv put secret/prjname/$service/dev @ms-identity-dev.json
    #vault kv patch secret/prjname/$service/prod application.security.authentication.jwt.base64-secret="NDA4YTI5MGY5NWY5MjcxMDMzNGIzYjQwYTllZjczMGY"
    #curl -s -X GET -H "X-Vault-Token:ed129adf-8218-c61b-1325-3c6f9a9d12ef" http://192.168.9.222:8200/v1/secret/data/prjname/ms-auth/prod | jq .data.data
    #vault kv get secret/prjname/$service/prod
done
