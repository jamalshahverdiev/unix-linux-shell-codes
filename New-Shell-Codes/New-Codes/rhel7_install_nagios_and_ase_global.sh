#!/bin/bash

trsearch=$(cat /root/.bashrc | grep TEMP | awk '{ print $2 }' | cut -f1 -d'=')
tmrsearch=$(cat /root/.bashrc | grep TMP | awk '{ print $2 }' | cut -f1 -d'=')

if [ "$trsearch" = "TEMP" -a "$tmrsearch" = "TMP" ]
then
    echo "TEMP variable is already exists in the Operation system"
    echo "Probably ASE is already installed and configured. Please check services!!!"
else
    echo "export TEMP=/opt/ASE/tmp" >> /root/.bashrc
    echo "export TMP=/opt/ASE/tmp" >> /root/.bashrc
    source /root/.bashrc

    if [ ! -d "/opt/ASE/tmp" ]
    then
        mkdir -p /opt/ASE/tmp
    fi
    # You need change RPM package path if it will be different than, /otp
    rpm -ivh ase-1.05-34.x86_64.rpm

    srvstat=$(systemctl status ase | grep Active | awk '{ print $2 }')
    startstat=$(chkconfig --list ase 2> /dev/null | awk '{ print $(NF-3)}')

    if [ "$srvstat" = "active" -a "$startstat" = "3:on" ]
    then
        echo "ASE service is successfully installed and configured!!!"
    else
        echo "There is some problem with the installation!!!"
        echo "The service is not running!!!"
    fi
fi

echo "Installtion of NaCl!!!"
# You need change RPM package path if it will be different than, /otp
rpm -ivh nacl-1.8.0.5-2.x86_64.rpm

nagcron=$(su - nagios -c "crontab -l | grep nagios" | awk '{ print $6 }')
nagsrvchek=$(su - nagios -c '/home/nagios/NaCl/NaCl -s 155.45.173.13 | grep Hello' | cut -f1 -d'!')
if [ "$nagcron" = "/home/nagios/NaCl/NaCl" -a "$nagsrvchek" = "Hello" ]
then
    echo "Nagios successfully installed and configured!!!"
fi

echo 