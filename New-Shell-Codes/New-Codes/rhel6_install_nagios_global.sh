#!/bin/bash

tsearch=$(cat /root/.bashrc | grep TEMP | awk '{ print $2 }' | cut -f1 -d'=')

if [ "$tsearch" = "TEMP" ]
then
    echo "TEMP variable is already exists in the Operation system"
else
    echo "export TEMP=/opt/nagios/tmp" >> /root/.bashrc
	echo "export TMP=/opt/nagios/tmp" >> /root/.bashrc
fi

mkdir -p /opt/nagios/tmp/p2xtmp-4388/ && chown -R nagios:nagios /opt/nagios

rpm -ivh ase-1.05-34.x86_64.rpm

checkase=$(ps waux | grep 'ase start' | grep -v grep | awk '{ print $(NF) }')
checkservice=$(chkconfig --list | grep ase | awk '{ print $(NF-3)} ')

if [ "$checkase" = "start" ] && [ "$checkservice" = "3:on" ]
then
    echo "ASE is already installed and configured!!!"
else
    echo "There is some problem at the installation time and ase is not running"
fi

rpm -ivh nacl-1.8.0.5-2.x86_64.rpm

croncheck=$(su - nagios -c "crontab -l | grep nagios" | awk '{ print $6 }')

if [ "$croncheck" = "/home/nagios/NaCl/NaCl" ]
then
    echo "NaCl package is successfully installed and configured!!!"
else
    echo "There are some errors at the installation process!!!"
fi