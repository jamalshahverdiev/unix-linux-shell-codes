#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  createPolicyAndNewRole.sh
# 
#         USAGE:  ./createPolicyAndNewRole.sh 
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
#       CREATED:  05/08/2020 03:15:08 PM +04
#      REVISION:  ---
#===============================================================================

if [ $# != 2 ]
then
    echo "Usage: ./$(basename $0) vaultIPaddress 'vaultROOTtoken'"
    exit 93
fi

ipAddr=$1
VAULT_TOKEN=$2
declare -A vault_arr rule_arr
vault_arr=(
    [prjname_dev_approle]=prjname_dev_policy
    [prjname_preprod_approle]=prjname_pre_policy
    [prjname_prod_approle]=prjname_prod_policy
)

rule_arr=(
    [prjname_dev_policy]=dev
    [prjname_pre_policy]=preprod
    [prjname_prod_policy]=prod
)

ruleString=$(echo '{"path": { "secret/data/prjname/+/rule_name": {"capabilities": ["create","read","list","update","delete"]}}}' | jq '@json')
policyString=$(echo '{"policies": ["policy_name"]}' | jq -r '@json')

# Create iterated new policy from 'rule_arr' array:
for policy_name in "${!rule_arr[@]}"
do
    envRuleString=$(echo $ruleString | sed "s/rule_name/${rule_arr[$policy_name]}/g")
    payload='{"policy":'"${envRuleString}"'}'
    curl -s -X POST -H "X-Vault-Token:$VAULT_TOKEN" -d $(echo $payload) "http://$ipAddr:8200/v1/sys/policy/$policy_name" | jq
done


# Create new roles with names iterated names inside of the $role_name:
for role_name in "${!vault_arr[@]}"
do
    policyNameString=$(echo $policyString | sed "s/policy_name/${vault_arr[$role_name]}/g")
    curl -s -H "X-Vault-Token: $VAULT_TOKEN" -X POST -d $policyNameString http://$ipAddr:8200/v1/auth/approle/role/$role_name
done

# Create Role_ID and Secret_ID in base64 format by Role names:
for rolename in "${!vault_arr[@]}"
do
    echo '####################################################'
    echo "Role name: $rolename"
    roleId=$(curl -s --header "X-Vault-Token: $VAULT_TOKEN" http://$ipAddr:8200/v1/auth/approle/role/$rolename/role-id | jq -r .data.role_id)
    #echo "Role ID in base64: $(echo -n "$roleId" | base64)"
    echo "Role ID cleartext: $(echo $roleId)"
    secretID=$(curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request POST http://$ipAddr:8200/v1/auth/approle/role/$rolename/secret-id | jq -r .data.secret_id)
    #echo "Secret ID in base64: $(echo -n "$secretID" | base64)"
    echo "Secret ID in cleartext: $(echo $secretID)"
    echo
done

