#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  installLatestBashCentos7.sh
# 
#         USAGE:  ./installLatestBashCentos7.sh 
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
#       CREATED:  09/08/2019 04:13:06 PM +04
#      REVISION:  ---
#===============================================================================

#!/usr/bin/env bash

bashVersion='5.0'

compileInstallBash() {
    wget http://ftp.gnu.org/gnu/bash/bash-$bashVersion.tar.gz
    tar xf bash-$bashVersion.tar.gz && cd bash-$bashVersion
    ./configure
    make
    make install
}

if [ $(cat /etc/os-release | grep ^ID= | cut -f2 -d'=' | tr -d '"') = 'centos' -a $(cat /etc/os-release | grep ^VERSION_ID | cut -f2 -d'=' | tr -d '"') = '7' ]
then
    yum groupinstall "Development Tools" "Legacy Software Development"
elif [ $(cat /etc/os-release | grep ^ID= | cut -f2 -d'=' | tr -d '"') = 'debian' -a $(cat /etc/os-release | grep ^VERSION_ID | cut -f2 -d'=' | tr -d '"') = '9' ]
then
    apt-get install -y build-essential
fi

compileInstallBash




