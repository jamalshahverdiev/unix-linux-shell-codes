#!/bin/bash

#yum -y remove nacl
#yum -y remove ase
#
#rm -rf /opt/nagios
#rm -rf /opt/ASE

homefolder="/home/nagios"
nagioshomefunc() {
    $(mv /home/nagios /root/`date +%Y%m%d-%H%M%S`-nagios)
    $(ln -s /opt/nagios/ /home/nagios)

    tnsearch=$(cat /home/nagios/.bashrc | grep TEMP | awk '{ print $2 }' | cut -f1 -d'=' 2> /dev/null)
    tnrsearch=$(cat /home/nagios/.bashrc | grep TMP | awk '{ print $2 }' | cut -f1 -d'=' 2> /dev/null)

    if [ "$tnsearch" = "TEMP" -a "$tnrsearch" = "TMP" ]
    then
        echo "TEMP variable is already exists in the Operation system"
    else
        $(mkdir /opt/nagios; cp -rn /etc/skel/.[^.]* /home/nagios/)
        echo "export TEMP=/opt/nagios/tmp" >> /home/nagios/.bashrc
        echo "export TMP=/opt/nagios/tmp" >> /home/nagios/.bashrc
        $(chown -R nagios:nagios /home/nagios/)
        $(source /home/nagios/.bashrc)
        # You need change RPM package path if it will be different than, /otp
        rpm -ivh nacl-1.8.0.5-2.x86_64.rpm
    fi

    croncheck=$(su - nagios -c "crontab -l | grep nagios" | awk '{ print $6 }')
    nagsrvchek=$(su - nagios -c '/home/nagios/NaCl/NaCl -s 155.45.173.13 | grep Hello' | cut -f1 -d'!')
    if [ "$croncheck" = "/home/nagios/NaCl/NaCl" -a "$nagsrvchek" = "Hello" ]
    then
        echo "NaCl package is successfully installed and configured!!!"
    else
        echo "There are some errors at the installation process!!!"
    fi
}
searchasevars_and_install (){
    trsearch=$(cat /root/.bashrc | grep TEMP | awk '{ print $2 }' | cut -f1 -d'=')
    tmrsearch=$(cat /root/.bashrc | grep TMP | awk '{ print $2 }' | cut -f1 -d'=')
    if [ "$trsearch" != "TEMP" -a "$tmrsearch" != "TMP" ]
    then
        echo "export TEMP=/opt/ASE/tmp" >> /root/.bashrc
        echo "export TMP=/opt/ASE/tmp" >> /root/.bashrc
        . /root/.bashrc
        # You need change RPM package path if it will be different than, /otp
        rpm -ivh ase-1.05-34.x86_64.rpm
    else
        echo "Temp variables is already exists for root user!!!"
        . /root/.bashrc
        # You need change RPM package path if it will be different than, /otp
        rpm -ivh ase-1.05-34.x86_64.rpm
    fi
}
check_ase_service(){
    checkase=$(ps waux | grep 'ase start' | grep -v grep | awk '{ print $(NF)}')
    checkservice=$(chkconfig --list | grep ase | awk '{ print $(NF-3)}')

    if [ "$checkase" = "start" ] && [ "$checkservice" = "3:on" ]
    then
        echo "ASE is already installed and configured!!!"
    else
        echo "There is some problem at the installation time and ase is not running"
    fi
}
ase_install_and_configure() {
    if [ -d "/opt/ASE" -a "searchase=$(rpm -qa | grep ^ase | cut -f1 -d'-')" != "ase" ]
    then
        searchasevars_and_install
        check_ase_service
    fi
}
if [ -L ${homefolder} ]
then
    if [ -e ${homefolder} ]
    then
        echo "Link is already exists and working!!!"
    else
        echo "Link is already exists but, broken"
        unlink /home/nagios
        nagioshomefunc
        ase_install_and_configure
    fi
elif [ -e ${homefolder} ]
then
    echo "It is not Symlink"
    nagioshomefunc
    ase_install_and_configure
else
    echo "It is not folder other the of file or folder.!!!"
    nagioshomefunc
    ase_install_and_configure
fi
