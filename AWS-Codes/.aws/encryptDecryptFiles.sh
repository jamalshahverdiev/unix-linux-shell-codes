#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  encryptDecryptFiles.sh
# 
#         USAGE:  ./encryptDecryptFiles.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Jamal Shahverdiev (), jamal.shahverdiev@gmail.com
#       COMPANY:  Open Source Corporation
#       VERSION:  1.0
#       CREATED:  09/07/2019 05:36:19 PM +04
#      REVISION:  ---
#===============================================================================
# 100 exit code: means input value empty

fileList='config credentials'
InstallAnsible() {
    osType=$(cat /etc/os-release | grep '^ID=' | awk -F '=' '{ print $2 }' | tr -d '"')
    osVersion=$(cat /etc/os-release | grep '^VERSION_ID=' | awk -F '=' '{ print $2 }' | tr -d '"')
    if [ $osType = centos -a $osVersion = 7 ]
    then
        yum -y install epel-release
        yum -y install python-pip
        pip install ansible awscli
    elif [ $osType = debian -a $osVersion = 9 ]
    then
        apt install -y python-pip
        pip install ansible awscli
    fi
}

read -sp "Please enter Ansible Vault password to decrypt AWS credentials file: " vaultpass
echo && echo

if [ -z $vaultpass ]
then
    echo "Entered value cannot be empty!!!"
    exit 100
else
    echo $vaultpass > password_file
fi

#### Encrypt files
ecryptFiles(){
for file in $1
do
    ansible-vault --vault-id @password_file encrypt $file
done
}

#### Decrypt files
decryptFiles(){
for file in $1
do
    ansible-vault --vault-id @password_file decrypt $file
done
}

if [ ! -f /usr/bin/ansible -o ! -f /bin/aws ]
then
    InstallAnsible
fi

#ecryptFiles "$fileList"
decryptFiles "$fileList"

rm -rf password_file
