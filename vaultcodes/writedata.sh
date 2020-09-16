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

#serviceNames='
#acs-activemq
#acs-alfresco
#adp-iamas
#adp-mkr
#bff-cashier
#bff-underwriter
#gw-branch
#kb-workplace
#ms-account
#ms-auth
#ms-claim
#ms-content
#ms-credit
#ms-credit-contract
#ms-customer
#ms-customer-product
#ms-customer-search
#ms-dict-reader
#ms-discount
#ms-document
#ms-guarantor
#ms-reject-history
#ms-scoring
#ms-teller
#adp-cms
#adp-scoring
#adp-zeus-auth
#adp-zeus-db
#gw-cpc
#'

serviceNames='
bpm-manager
'

getProdToken=$(curl -s --request POST --data '{"role_id": "", "secret_id": ""}' http://192.168.9.222:8200/v1/auth/approle/login | jq -r .auth.client_token)
#getPreToken=$(curl -s --request POST --data '{"role_id": "", "secret_id": ""}' http://192.168.9.222:8200/v1/auth/approle/login | jq -r .auth.client_token)
#getDevToken=$(curl -s --request POST --data '{"role_id": "", "secret_id": ""}' http://192.168.9.222:8200/v1/auth/approle/login | jq -r .auth.client_token)

#getData=$(curl -s -X GET -H "X-Vault-Token:7e37e506-66ce-a77d-eaec-030ca4cbb0b0" 'http://192.168.9.222:8200/v1/secret/data/project_name/ms-claim/prod?version=1' | jq -r .data.data)
vault login $getProdToken
#vault login $getPreToken
#vault login $getDevToken
for service in $serviceNames
do
    vault kv put secret/atlas/$service/prod @bpm-manager-prod.json
    #vault kv put secret/atlas/$service/preprod @bpm-manager-pre.json
    #vault kv put secret/atlas/$service/dev @bpm-manager-dev.json
    #vault kv patch secret/atlas/$service/prod application.security.authentication.jwt.base64-secret="NDY2MWFlOTg5NmVlYjYyYWI4OGJkOWQzN2EwY2U2NYjQwYTllZjczMGY"
    #curl -s -X GET -H "X-Vault-Token:ed129adf-8218-c61b-1325-3c6f9a9d12ef" http://192.168.9.222:8200/v1/secret/data/atlas/ms-auth/prod | jq .data.data
    #vault kv get secret/atlas/$service/prod
done
