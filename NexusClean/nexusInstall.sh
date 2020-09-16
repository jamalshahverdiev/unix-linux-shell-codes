#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  nexusInstall.sh
# 
#         USAGE:  ./nexusInstall.sh 
# 
#   DESCRIPTION:  Script detect Linux platform and Install/Configure Nexus
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Jamal Shahverdiev (), jamal.shahverdiev@gmail.com
#       COMPANY:  Pronet LLC
#       VERSION:  1.0
#       CREATED:  10/20/2019 01:11:01 PM +04
#      REVISION:  ---
#===============================================================================


osName=$(cat /etc/os-release | grep '^ID=' | cut -f2 -d'=' | tr -d '"')
osVersion=$(cat /etc/os-release | grep 'VERSION_ID' | cut -f2 -d'=' | tr -d '"')

if [ $osName = 'centos' -a $osVersion = '7' ]
then
    yum install -y java-1.8.0-openjdk-devel.x86_64
    adduser nexus
elif [ $osName = 'debian' -a $osVersion = '9' ]
then
    apt update && apt dist-upgrade -y && apt -y autoremove
    apt install -y openjdk-8-jdk
    useradd nexus
fi

pushd /opt/ && wget -O nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz
tar -xf nexus.tar.gz && mv nexus-3* nexus
chown -R nexus:nexus /opt/nexus && chown -R nexus:nexus /opt/sonatype-work
sed -i 's/""/"nexus"/g;s/\#//g' /opt/nexus/bin/nexus.rc

cat <<EOF > /etc/systemd/system/nexus.service
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

systemctl enable nexus && systemctl start nexus

