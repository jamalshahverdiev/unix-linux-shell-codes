#!/bin/bash
#######################################################
# Setup Active Directory integration for RHEL 6|7 and SLES12
#
# This script is created by the kickstart 
#
# v0.1beta	150424	TJH	Initial Creation
# v0.2beta	150427	TJH/SM	Fixes
# v0.3beta	150603  TJH	Fixes
# v0.4beta	150622  TJH	Fixes
# Exit code 43 means: antered argument count is less than 4
#######################################################
#
# Variables

#AD_DOMAIN="LABDEV.LOCAL"
AD_DOMAIN=$1
#AD_USER="Administrator"
AD_USER=$2
#AD_SVR="WEBDC01.LABDEV.LOCAL"
AD_SVR=$5
# ouvar takes argument from VRO and convert this for DC join.
#ouvar=$(echo $4|sed 's/ou=//g; s/dc=.*//g; s/\,/ /g'|tr ' ' '\n'|tac |tr '\n' ' '|tr ' ' '/'|awk '{print substr($0, 2, length($0) - 2)}')
ouvar=$(echo $4|sed 's/ou=//g; s/dc=.*//g; s/\,/ /g'|tr ' ' '\n'|tac|tr '\n' ' '|tr ' ' '/'|sed 's/^\///g; s/\/$//g;')
AD_FLDR=$ouvar
DOMAIN_PASSWORD=$(echo $3 | base64 --decode && echo)
LOW_AD_DOMAIN=$(echo $AD_DOMAIN | tr '[:upper:]' '[:lower:]')
LOW_AD_SVR=$(echo $AD_SVR | tr '[:upper:]' '[:lower:]')
AD_DOM_DOTS=$(echo $AD_DOMAIN | grep "\." | wc -l)
if [ "$AD_DOM_DOTS" -eq "0" ]; then
    WRKGRP=$AD_DOMAIN
else
    WRKGRP=$(echo $AD_DOMAIN | awk -F'.' '{print $1}')
fi

allargs="$#"
usage() {
    if [ "$allargs" != "5" ]
	then
	    echo "Script usage is: $(basename $0) ADNAME ADUSER ADFQDN OUPATH ADPASSWD" | tee -a ${LOG}
		exit 43
    fi
}
usage
#
AD_SETUP_DIR=/sysmgt/bin/dir_setup
HOSTS=/etc/hosts
KRBCONF=/etc/krb5.conf
SMBCONF=/etc/samba/smb.conf
SMBCACHE=/var/cache/samba
SSSDCONF=/etc/sssd/sssd.conf
SSHDCONF=/etc/ssh/sshd_config
NSSCONF=/etc/nsswitch.conf
PAMCONF=/etc/pam.d/system-auth-custom
PAMPWCONF=/etc/pam.d/password-auth-custom
SLESPAM="common-account-pc common-auth-pc common-password-pc common-session-pc"
SUDO_ATOSMGMT=/etc/sudoers.d/atosmgmt
LOG=/opt/$(basename $0 | cut -f1 -d'.').log
CURRHOST=$(hostname -s)
rhelrpms="sssd samba-common krb5-workstation oddjob oddjob-mkhomedir pam_krb5"
slesrpms="samba-client samba-client-32bit samba-winbind samba-winbind-32bit krb5-client"
#
ADGRP_SSH=delg-lx-l-sshlogin
ADGRP_SUDO=delg-lx-l-sudo-root
#AD_FLDR="Admin/Services/NIXsrv/Servers"
#AD_FLDR="Computers"


#
# Functions 
# This function is going to check platform and set "relver" variable for release and version of Linux.
checkver () {
    if [ -f "/etc/redhat-release" ]
    then
        version=$(cat /etc/redhat-release | awk '{ print $(NF-1)}' | cut -f1 -d'.')

        if [ "$version" = "6" ]
        then
            echo "Red Hat version is $version" | tee -a ${LOG}
            relver="rhel$version"
        elif [ "$version" = "7" ]
        then
            echo "Red Hat version is $version" | tee -a ${LOG}
            relver="rhel$version"
        fi
    elif [ -f "/etc/SuSE-release" ]
    then
        version=$(cat /etc/SuSE-release | grep -i version | awk '{print $(NF)}')
        echo "SLES version is $version" | tee -a ${LOG}
        relver="sles$version"
    else
        version="unknown"
        echo "The os type and version is not determined!!!" | tee -a ${LOG}
    fi
}

checkver

# This function is going to check RPM's which need for domain integration.
rpm_check () {
    for RPM in "$@"
    do
        rpm -q $RPM > /dev/null
#        echo $RPM
        
        if [ $? -ne 0 ]
        then
            echo "${date} RPM $RPM is not installed." | tee -a ${LOG}
            RPMCHECK=1
        fi
    done

    if [ $RPMCHECK ]; then
        echo "${date} Prerequisite RPMs missing.  Aborting." | tee -a ${LOG}
        exit 1;
    else
        echo "${date} Prerequisite RPMs found.  Continuing." | tee -a ${LOG}
    fi
}

# Function is going to configure hotname for RHEL7 and SLES12
netconf_sles12_rhel7() {
    cp ${NETWORK} ${NETWORK}.$(date +%Y%m%d-%H%M%S)
	printf '%s.%s\n' $CURRHOST $AD_DOMAIN > $NETWORK 
}

# This function is going to configure hostname for RHEL6|7 and SLES12
configure_network () {
    echo "Configuring Linux network file" | tee -a ${LOG}
    if [ "$relver" = "rhel6" ]
    then 
        NETWORK=/etc/sysconfig/network
        cp ${NETWORK} ${NETWORK}.$(date +%Y%m%d-%H%M%S) 
        sed -i 's/^HOSTNAME/#HOSTNAME/' $NETWORK
		printf 'HOSTNAME=%s.%s\n' $CURRHOST $AD_DOMAIN >> $NETWORK 
    elif [ "$relver" = "rhel7" ]
    then 
        NETWORK=/etc/hostname
        netconf_sles12_rhel7
    elif [ "$relver" = "sles12" ]
	then
	    NETWORK=/etc/HOSTNAME
        netconf_sles12_rhel7
		hostname -v $CURRHOST
    else
        echo "Script is not determined the type of Operation System!!!" | tee -a ${LOG}
    fi	
}

# Function is confiuring hosts file for all Linux's
configure_hosts () {
    echo "Configuring hosts file" | tee -a ${LOG}
    cp ${HOSTS} ${HOSTS}.$(date +%Y%m%d-%H%M%S)
    IP=$(grep $CURRHOST $HOSTS | grep -v '^#' | awk '{print $1}')
    sed -i "/$CURRHOST/s/^/#/" $HOSTS
    printf '%s\t%s.%s\t%s\n' $IP $CURRHOST $AD_DOMAIN $CURRHOST >> $HOSTS
}

# Function is going to backup all files and then configure files for AD join
configure_authconfig () {
  echo "Backing up authconfig settings ..." | tee -a ${LOG}
  authconfig --savebackup=mybackup-$(date +%Y%m%d-%H%M%S)

  echo "Setting authconfig parameters ..." | tee -a ${LOG}
  authconfig --enablesssdauth --enablesssd --enablemkhomedir --enablelocauthorize --enablerfc2307bis --disablefingerprint --updateall
}

# Function configuring krb5.conf file for RHEL6|7
configure_kerberos () {
  echo "Backing up kerberos config file ..." | tee -a ${LOG}
  mv $KRBCONF $AD_SETUP_DIR/krb5.conf.orig-$(date +%Y%m%d-%H%M%S)

cat <<EOS > $KRBCONF
[logging]
default = FILE:/var/log/krb5libs.log
kdc = FILE:/var/log/krb5kdc.log
admin_server = FILE:/var/log/kadmind.log

[libdefaults]
default_realm = $AD_DOMAIN
dns_lookup_realm = false
dns_lookup_kdc = true
ticket_lifetime = 24h
renew_lifetime = 7d
rdns = false
forwardable = yes

[realms]
$AD_DOMAIN = {
  kdc = $AD_SVR
  admin_server = $AD_SVR
}

[domain_realm]
.$LOW_AD_DOMAIN = $AD_DOMAIN
$LOW_AD_DOMAIN = $AD_DOMAIN
EOS

  chmod 644 $KRBCONF
}

# Function configuring krb5.conf file for SLES12
configure_kerberos_sles () {
  echo "Backing up kerberos config file ..." | tee -a ${LOG}
  mv $KRBCONF $AD_SETUP_DIR/krb5.conf.orig-$(date +%Y%m%d-%H%M%S)

cat <<EOF > $KRBCONF
[logging]
        default = FILE:/var/log/krb5libs.log
        kdc = FILE:/var/log/krb5kdc.log
        admin_server = FILE:/var/log/kadmind.log

[libdefaults]
        default_realm = $AD_DOMAIN
        dns_lookup_realm = true
        dns_lookup_kdc = true
        ticket_lifetime = 24h
        renew_lifetime = 7d
        forwardable = true
        clockskew = 300
[domain_realm]
        .labdev.local = $AD_DOMAIN
[realms]
$AD_DOMAIN = {
        kdc = $LOW_AD_SVR
        default_domain = $LOW_AD_DOMAIN
        admin_server = $LOW_AD_SVR
}
[appdefaults]
pam = {
        ticket_lifetime = 1d
        renew_lifetime = 1d
        forwardable = true
        proxiable = false
        minimum_uid = 1
}
EOF
}

# Function configuring samba file for RHEL6|7
configure_samba () {
    if [ -d $SMBCACHE ]; then
        :
    else
        mkdir -p $SMBCACHE
        chmod 0755 $SMBCACHE
    fi

    echo "Create SAMBA Configuration file ..."
    if [ -f $SMBCONF ]; then
        mv $SMBCONF $AD_SETUP_DIR/smb.conf.orig-$(date +%Y%m%d-%H%M%S)
    fi

cat <<EOS > $SMBCONF
[global]
  workgroup = $WRKGRP
  client signing = yes
  client use spnego = yes
  client ldap sasl wrapping = sign
  kerberos method = secrets and keytab
  log file = /var/log/samba/%m.log
  realm = $AD_DOMAIN
  security = ads
EOS
}

# Function configuring samba file for SLES12
configure_samba_sles () {
cat <<EOS > $SMBCONF
[global]
        workgroup = $WRKGRP
        kerberos method = secrets and keytab
        log file = /var/log/samba/%m.log
        realm = $AD_DOMAIN
        security = ADS
        usershare allow guests = No
  #idmap gid = 10000-20000
  #idmap uid = 10000-20000
        template homedir = /home/%D/%U
        template shell = /bin/bash
        winbind refresh tickets = yes
        winbind use default domain = yes
        passdb backend = tdbsam
        idmap gid = 10000-20000
        idmap uid = 10000-20000
EOS
}

# Function configuring PAM files for SLES12
configure_pam_sles () {
    echo "Saving PAM configs" | tee -a ${LOG}
    for FILE in "$@"
    do
#        echo $FILE
        cp /etc/pam.d/${FILE} ${FILE}.$(date +%Y%m%d-%H%M%S)
    done
    pam-config -a --winbind --mkhomedir --mkhomedir-umask=0077
    
    if [ $? != 0 ]; then
        echo "Error updating PAM configuration" | tee -a ${LOG}
    fi
}

# Function configuring sssd.conf file for RHEL6|7
configure_sssd () {
  echo "Create SSSD Configuration file ..."
  if [ -f $SSSDCONF ]; then
      mv $SSSDCONF $AD_SETUP_DIR/sssd.conf.orig-$(date +%Y%m%d-%H%M%S)
  fi

cat <<EOS > $SSSDCONF
[sssd]
domains = $AD_DOMAIN
services = nss, pam
config_file_version = 2

[domain/$AD_DOMAIN]
id_provider = ad
access_provider = ad

#ad_server = $AD_SVR
#ad_hostname = $HOSTNAME
#ad_domain = $AD_DOMAIN

krb5_realm = $AD_DOMAIN
krb5_store_password_if_offline = True
krb5_canonicalize = false
#krb5_fast_principal =

override_shell = /bin/bash
fallback_homedir = /home/%u
enumerate = True

cache_credentials = True
use_fully_qualified_names = False

[nss]
homedir_substring = /home
filter_users = root,bin,daemon,adm,lp,sync,mail,ftp,nobody,dbus,sssd,polkitd,tss,ntp,postfix,sshd,atosadm,nagios

[pam]

EOS

  chown root:root $SSSDCONF
  chmod 0600 $SSSDCONF

}

# Function configuring nsswitch.conf file file for SLES12
configure_nsswitch () {
    echo "Configuring nsswitch.conf" | tee -a ${LOG}
    cp ${NSSCONF} ${NSSCONF}.$(date +%Y%m%d-%H%M%S)
    sed -i -r -e 's/^passwd:\s+compat$/passwd:\tcompat\twinbind/' ${NSSCONF}
    sed -i -r -e 's/^group:\s+compat$/group:\tcompat\twinbind/' ${NSSCONF}
}

# Function configuring PAM files for RHEL6|7
configure_pam () {
    echo "Saving PAM configs ..."
    cp -p $PAMCONF $AD_SETUP_DIR/system-auth-custom.orig-$(date +%Y%m%d-%H%M%S)
    cp -p $PAMPWCONF $AD_SETUP_DIR/password-auth-custom.orig-$(date +%Y%m%d-%H%M%S)

    echo "Configure PAM setup to work with SSSD ..." 
    sed -i -e '/auth        \[success=1/d' $PAMCONF
    sed -i -e '/auth        requisite     pam_succeed/d' $PAMCONF
  
    sed -i -e '/auth        required      pam_faillock.so/a\auth        sufficient    pam_unix.so nullok try_first_pass\nauth        requisite     pam_succeed_if.so uid >= 1000 quiet\nauth        sufficient    pam_sss.so use_first_pass' $PAMCONF
    sed -i -e '/auth        sufficient    pam_faillock.so authsucc/a\auth        \[success=1 default=bad\]    pam_unix.so' $PAMCONF
    sed -i -e '/account     sufficient    pam_succeed_if.so/a\account \[default=bad success=ok user_unknown=ignore\] pam_sss.so' $PAMCONF
    sed -i -e '/password    sufficient    pam_unix.so/a\password    sufficient    pam_sss.so use_authtok' $PAMCONF
    sed -i -e '/session     required      pam_limits.so/a\session     optional      pam_oddjob_mkhomedir.so skel=/etc/skel umask=0077' $PAMCONF
    sed -i -e '/session     required      pam_unix.so/a\session     optional      pam_sss.so' $PAMCONF

    sed -i -e '/auth        \[success=1/d' $PAMPWCONF
    sed -i -e '/auth        requisite     pam_succeed/d' $PAMPWCONF

    sed -i -e '/auth        required      pam_faillock.so/a\auth        sufficient    pam_unix.so nullok try_first_pass\nauth        requisite     pam_succeed_if.so uid >= 1000 quiet\nauth        sufficient    pam_sss.so use_first_pass' $PAMPWCONF
    sed -i -e '/auth        sufficient    pam_faillock.so authsucc/a\auth        \[success=1 default=bad\]    pam_unix.so' $PAMPWCONF
    sed -i -e '/session     required      pam_limits.so/a\session     optional      pam_oddjob_mkhomedir.so skel=/etc/skel umask=0077' $PAMPWCONF
    sed -i -e '/session     required      pam_unix.so/a\session     optional      pam_sss.so' $PAMPWCONF
}

# Kerberos initialization for RHEL6|7 and SLES12
initialise_kerberos () {
  echo " " | tee -a ${LOG}
  echo "Generating Kerberos Ticket for user $AD_USER" | tee -a ${LOG}
  echo "User should have rights to join computer to domain $AD_DOMAIN" | tee -a ${LOG}
  echo "You will be prompted for the users password" | tee -a ${LOG}
  # To trace: KRB5_TRACE=/dev/stdout kinit  Administrator
  printf %s ${DOMAIN_PASSWORD} | kinit ${AD_USER}
  echo " " | tee -a ${LOG}
  echo "If successful ticket information should be shown below" | tee -a ${LOG}
  echo " " | tee -a ${LOG}
  klist
}

# Joining to the Domain Controller and create computer name in selected OU
join_ad () {
    echo " " | tee -a ${LOG}
    echo "Attempting to join AD domain ..." | tee -a ${LOG}
    echo "Trying to create computer in folder "$AD_FLDR | tee -a ${LOG}
    # To trace: net ads join -k createcomputer="$AD_FLDR" -d 10 > join.log 2>&1
    net ads join -k createcomputer="$AD_FLDR" 
    rc2=$?
    
    if [ "$rc2" -ne "0" ]; then
        echo "## ERROR - net ads join process failed ... aborting" | tee -a ${LOG}
        logger -p local2.crit -t AD_SETUP "Failed - Problem with net ads join" 
        exit 1
    fi

    echo " " | tee -a ${LOG}
    echo "Running test to see if join was correct" | tee -a ${LOG}
    echo " " | tee -a ${LOG}
    net ads testjoin
    rc3=$?
    if [ "$rc3" -ne "0" ]; then
        echo "## ERROR - net ads testjoin process failed ... " | tee -a ${LOG}
        logger -p local2.crit -t AD_SETUP "Failed - Problem with net ads testjoin"
    fi
}

# Restart all needed services for RHEL7
rhel7_restart_daemons () {
    echo "restarting sssd, oddjobd and sshd daemons ..."
    systemctl enable sssd oddjobd 
    systemctl restart oddjobd.service
    systemctl restart sssd.service
    systemctl restart sshd.service
    systemctl restart network 
}

# Restart all needed services for RHEL6
rhel6_restart_daemons () {
    echo "restarting sssd, oddjobd and sshd daemons ..." | tee -a ${LOG}
    chkconfig sssd on && chkconfig oddjobd on
    service oddjobd restart
    service sssd restart
    service sshd restart
    service network restart
}

# Restart all needed services for SLES12
sles12_restart_daemons () {
    echo "Restarting Winbind" | tee -a ${LOG}
    systemctl enable winbind nscd
	systemctl restart winbind
	systemctl restart nscd
}

# Configure SSHD for all servers
configure_sshd () {
    echo "Configuring sshd ..." | tee -a ${LOG}
    sed -i "/AllowGroups/s/$/ $ADGRP_SSH/" $SSHDCONF
}

# Configure SUDO for RHEL6|7
configure_sudo () {
    echo "Configuring sudo for Admin users ..." | tee -a ${LOG}
    echo "%$ADGRP_SUDO	ALL=(ALL)    ALL" >> $SUDO_ATOSMGMT
}

# Function flow for RHEL6|7 servers
rhel_functions_flow() {
    configure_network
    configure_hosts
    configure_authconfig
    configure_kerberos
    configure_samba
    configure_sssd
    configure_pam
    initialise_kerberos
    join_ad
    authconfig --updateall
    configure_sshd
    configure_sudo
}

# Function flow for SLES12 server
sles_functions_flow() {
    configure_network
    configure_hosts
    configure_pam_sles $SLESPAM
    configure_samba_sles
    configure_kerberos
    configure_nsswitch
    initialise_kerberos
	join_ad
    configure_sshd
}

###################################################################
# Main

if [ "$AD_DOMAIN" = "" -o "$AD_USER" = "" -o "$AD_SVR" = "" ]; then
    echo "## ERROR - Insufficient information provided!!!" | tee -a ${LOG}
    echo "## ERROR - Please populate variables and rerun!!!" | tee -a ${LOG}
    logger -p local2.crit -t AD_SETUP "Failed - Variable values not provided"
    exit 1
fi

if [ "$relver" = "rhel7" ]
then
    echo "Red Hat version is $version" | tee -a ${LOG}
    #HOSTNAME=$(cat /etc/hostname | cut -f1 -d'.')
	rpm_check $rhelrpms
	rhel_functions_flow
	rhel7_restart_daemons
elif [ "$relver" = "rhel6" ]
then
    echo "Red Hat version is $version" | tee -a ${LOG}
    #HOSTNAME=$(cat /etc/sysconfig/network | grep -i hostname | cut -f2 -d'=')
	rpm_check $rhelrpms
	rhel_functions_flow
	rhel6_restart_daemons
elif [ "$relver" = "sles12" ]
then
    echo "SLES version is $version" | tee -a ${LOG}
	rpm_check $slesrpms
    sles_functions_flow
	sles12_restart_daemons
else
    echo "The os type and version is not determined!!!" | tee -a ${LOG}
fi

# Making script no executable as you dont really want to rerun it
chmod 0600 $AD_SETUP_DIR/ad_setup.sh

