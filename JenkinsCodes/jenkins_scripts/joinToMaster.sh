#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  joinToMaster.sh
# 
#         USAGE:  ./joinToMaster.sh 
# 
#   DESCRIPTION: Script to join Jenkins master with SWARM plugin
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Jamal Shahverdiev (), jamal.shahverdiev@gmail.com
#       COMPANY:  Pronet LLC
#       VERSION:  1.0
#       CREATED:  09/25/2019 10:08:54 AM CDT
#      REVISION:  ---
#===============================================================================


swarmClientVersion='3.9'
username='jenkins'

if [ $# -lt 5 ]
then
    echo "Usage: ./$(basename $0) JenkinsDomainOrIP JenkinsSrvUser JenkinsSrvPass SlaveName ExecuterCount"
    exit 100
fi

downloadSwarmClient(){
    mkdir -p /opt/$2
    wget -O /opt/$2/swarm-client-$1.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$1/swarm-client-$1.jar
}

createUser(){
    useradd -m -d /home/$1 -s /bin/nologin -c "Jenkins Slave User" -U $1
}

createSystemUnitFile(){
cat <<EOF > /etc/systemd/system/swarm$1slave.service
[Unit]
Description=Jenkins SWARM agent of Slave
Requires=network-online.target
After=network-online.target

[Service]
User=$1
Group=$1
PIDFile=/var/run/$1/$1.pid
PermissionsStartOnly=true
ExecStartPre=-/bin/mkdir -p /var/run/$1 /var/log/$1
ExecStartPre=/bin/chown -R $1:$1 /var/run/$1 /var/log/$1
ExecStart=/bin/bash -c "java -jar /opt/$1/swarm-client-$2.jar -master http://$3 -username $4 -password $5 -mode normal -name $6 -disableClientsUniqueId -executors $7 2>&1 >> /var/log/$1/$1-slave.log & echo \$! > /var/run/$1/$1.pid"
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
EOF
}

enableStartSlave(){
   systemctl daemon-reload
   systemctl enable swarm$1slave.service && systemctl start swarm$1slave.service
}

createUser $username
downloadSwarmClient $swarmClientVersion $username
createSystemUnitFile $username $swarmClientVersion $1 $2 $3 $4 $5
enableStartSlave $username
