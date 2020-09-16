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

serviceNames='adp-ldb'
export VAULT_ADDR='http://192.168.9.222:8200'
export VAULT_SKIP_VERIFY=true

rule_arr=(
    [adp-ldb]=dev
    [adp-ldb]=preprod
    [adp-ldb]=prod
)

getProdToken=$(curl -s --request POST --data '{"role_id": "", "secret_id": ""}' http://192.168.9.222:8200/v1/auth/approle/login | jq -r .auth.client_token)
#getPreToken=$(curl -s --request POST --data '{"role_id": "", "secret_id": ""}' http://192.168.9.222:8200/v1/auth/approle/login | jq -r .auth.client_token)
#getDevToken=$(curl -s --request POST --data '{"role_id": "", "secret_id": ""}' http://192.168.9.222:8200/v1/auth/approle/login | jq -r .auth.client_token)
#getData=$(curl -s -X GET -H "X-Vault-Token: 7e37e506-66ce-a77d-eaec-030ca4cbb0b0" 'http://192.168.9.222:8200/v1/secret/data/atlas/ms-claim/prod?version=1' | jq -r .data.data)
#vault login $getDevToken
vault login $getProdToken
#vault login $getPreToken
#for service in "${!rule_arr[@]}"
for service in $serviceNames
do
#    vault kv put secret/atlas/$service/${rule_arr[$service]} @adp-ldb.json
    vault kv put secret/atlasplatform/adp-ldb/prod @adp-ldb.json
    #vault kv patch secret/atlas/$service/prod application.security.authentication.jwt.base64-secret="NDY2NWY5MjcxMDMzNGIzYjQwYTllZjczMGY"
    #curl -s -X GET -H "X-Vault-Token: ed129adf-8218-c61b-1325-3c6f9a9d12ef" http://192.168.9.222:8200/v1/secret/data/atlas/ms-auth/prod | jq .data.data
    #vault kv get secret/atlas/$service/prod
done
