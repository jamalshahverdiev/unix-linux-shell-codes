#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  vaultGetRoleSecretOfRoles.sh
# 
#         USAGE:  ./vaultGetRoleSecretOfRoles.sh 
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
#       CREATED:  04/06/2020 10:39:20 AM +04
#      REVISION:  ---
#===============================================================================

approles='
prjname_dev_approle
prjname_preprod_approle
prjname_prod_approle
'

ipAddr=192.168.9.222
VAULT_TOKEN='ROOT_TOKEN'

for rolename in $approles
do
    echo '####################################################'
    echo "Role name: $rolename"
    roleId=$(curl -s --header "X-Vault-Token: $VAULT_TOKEN" http://$ipAddr:8200/v1/auth/approle/role/$rolename/role-id | jq -r .data.role_id)
    echo "Role ID in base64: $(echo -n "$roleId" | base64)"
    secretID=$(curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request POST http://$ipAddr:8200/v1/auth/approle/role/$rolename/secret-id | jq -r .data.secret_id)
    echo "Secret ID in base64: $(echo -n "$secretID" | base64)"
    echo
done
