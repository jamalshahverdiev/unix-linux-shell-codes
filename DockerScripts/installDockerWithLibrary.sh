#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  installDockerWithlibrary.sh
# 
#         USAGE:  ./installDockerWithlibrary.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Jamal Shahverdiev (), jamal.shahverdiev@gmail.com
#       COMPANY:  Pronet LLC
#       VERSION:  1.0
#       CREATED:  09/08/2019 05:14:15 PM +04
#      REVISION:  ---
#===============================================================================

InstallDocker() {
    osType=$(cat /etc/os-release | grep '^ID=' | awk -F '=' '{ print $2 }' | tr -d '"')
    osVersion=$(cat /etc/os-release | grep '^VERSION_ID=' | awk -F '=' '{ print $2 }' | tr -d '"')
    if [ $osType = centos -a $osVersion = 7 ]
    then
        yum install -y yum-utils device-mapper-persistent-data lvm2
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        yum install -y docker-ce docker-ce-cli containerd.io
        systemctl start docker && systemctl enable docker
        yum -y install epel-release && yum -y install python-pip
        pip install docker
    elif [ $osType = debian -a $osVersion = 9 ]
    then
        apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
        curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
        apt update && apt-get install -y docker-ce docker-ce-cli containerd.io
        systemctl start docker && systemctl enable docker 
        apt install -y python-pip
        pip install docker
    fi
    curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
}

if [ ! -f /bin/docker ]
then
    InstallDocker
fi
