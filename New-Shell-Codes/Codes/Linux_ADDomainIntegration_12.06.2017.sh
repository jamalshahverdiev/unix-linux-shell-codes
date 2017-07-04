#!/bin/sh
#
# Script to join a RHEL/SLES machine to Windows Active Directory
#
# Usage - configure_ADintegration.sh <domain> <ad user> <ad password> <RODC join 1 or 0> [<dom01-hostname>] [<dom02-hostname>]
#
# v001 - 2016-12-06 - Initial version, based on UK Cloud script
# v002 - 2016-12-07 - Modifications to support SLES (incomplete !)
# v003 - 2016-12-08 - Change arguments to be position based for VRO
# v004 - 2016-12-12 - Remove SSH and SUDO configuration and complete SLES
# v005 - 2016-12-15 - Bug fix.  Missing configure_sssd from RHEL section
# v006 - 2016-12-15 - Update password handling to cater for special characters
# v007 - 2016-12-15 - Update server's FQDN
# v008 - 2017-03-06 - Changed Logdir to /home/c-cloudauto0001
# v009 - 2017-06-12 - New function "configure_network_sles" with platform checking added for SLES. Check DC join and write to log file.
# Exit code "46": Means Linux server is not Joined to the Domain Controller correctly.

usage () {
   echo -e "Usage: $0 <domain> <ad user> <ad password> <RODC join 1 or 0> [dom01-hostname] [dom02-hostname]\n"
}

date=`date`
#LOGDIR=/tmp
LOGDIR=/home/c-cloudauto0001
#if [ ! -d "$LOGDIR" ]; then
#    echo "Log directory $LOGDIR does not exist."
#    exit 1
#fi

# LOG=$LOGDIR/ad-integration.log
LOG=$LOGDIR/postconfig.log
#echo ${date} >> ${LOG}
echo "Linux_ADDomainintegration: S---" >> $LOG

OS=unknown

if [ -f /etc/redhat-release ]; then
   OS=rhel
elif [ -f /etc/SuSE-release ]; then
   OS=sles
fi

if [ $OS == 'unknown' ]; then
    echo 'Unknown operating system' | tee -a ${LOG}
#    exit 1
fi


# Check that the required packages are installed
# 
# 
if [ $OS == 'rhel' ]; then
    # uncomment the following line when "pam_krb5" package will be added to default image
	# RQRDRPMS="sssd samba-common krb5-workstation oddjob oddjob-mkhomedir pam_krb5"
    RQRDRPMS="sssd samba-common krb5-workstation oddjob oddjob-mkhomedir"
elif [ $OS == 'sles' ]; then
    RQRDRPMS="samba-client samba-client-32bit samba-winbind samba-winbind-32bit krb5-client"
elif [ $OS == 'unknown' ]; then
    RQRDRPMS=""
fi

for RPM in $RQRDRPMS
do
    rpm -q $RPM > /dev/null
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

DOMAIN=$1
DOMAIN_USER=$2
#DOMAIN_PASSWORD=$3
DOMAIN_PASSWORDtmp=$3
DOMAIN_PASSWORD=$(echo $DOMAIN_PASSWORDtmp | base64 --decode && echo)
#printf %s $DOMAIN_PASSWORD >> $LOG
RODC=$4
DOM01=$5
DOM02=$6
CURRHOST=`hostname -s`

if [ -z "$DOMAIN" ]; then
   usage
   exit 1
fi

# Ensure DOMAIN is lowercase
DOMAIN="$(echo $DOMAIN | tr '[A-Z]' '[a-z]')"
REALM="$(echo $DOMAIN | tr '[a-z]' '[A-Z]')"

if [ -z "$DOMAIN_USER" ]; then
   usage
   exit 1
fi

if [ -z "$DOMAIN_PASSWORD" ]; then
   usage
   exit 1
fi

if [ -z "$RODC" ]; then
   usage
   exit 1
fi

if [ $RODC == 1 ]; then
   if [ -z "$DOM01" ]; then
      usage
      exit 1
   fi
   if [ -z "$DOM02" ]; then
      usage
      exit 1
   fi
fi

# Configuration Files
KRBCONF=/etc/krb5.conf
SMBCONF=/etc/samba/smb.conf
SMBCACHE=/var/cache/samba
SSSDCONF=/etc/sssd/sssd.conf
#SSHDCONF=/etc/ssh/sshd_config
#SSHDCONF=/etc/openssh/sshd_config
PAMCONF=/etc/pam.d/system-auth-custom
PAMPWCONF=/etc/pam.d/password-auth-custom
ODDJCONF=/etc/oddjobd.conf.d/oddjobd-mkhomedir.conf
#SUDO_ATOSMGMT=/etc/sudoers.d/atosmgmt
TMPKEYTAB=/tmp/temp.keytab
NSSCONF=/etc/nsswitch.conf
SLESPAM1=/etc/pam.d/common-account-pc
SLESPAM2=/etc/pam.d/common-auth-pc
SLESPAM3=/etc/pam.d/common-password-pc
SLESPAM4=/etc/pam.d/common-session-pc
HOSTS=/etc/hosts
NETWORK=/etc/sysconfig/network
NETWORKSLES=/etc/HOSTNAME


# Variables
#
# This may be too simplistic given, but should be a
# reasonable guess.
#
WRKGRP=`echo ${REALM} | awk -F'.' '{print $1}'`

echo "Domain is ${DOMAIN}" >> $LOG
echo "Realm is ${REALM}" >> $LOG
echo "Workgroup is ${WRKGRP}" >> $LOG
echo "Domain Controller 1 is ${DOM01}" >> $LOG
echo "Domain Controller 2 is ${DOM02}" >> $LOG
echo "RODC decision is ${RODC}" >> $LOG
echo "Domain User is ${DOMAIN_USER}" >> $LOG

# functions

configure_authconfig () {
    echo "Backing up authconfig" >> $LOG
    authconfig --savebackup=mybackup

    echo "Setting authconfig parameters" >> $LOG
    authconfig --enablesssdauth --enablesssd --enablemkhomedir --enablelocauthorize --enablerfc2307bis --disablefingerprint --updateall
}

configure_hosts () {
    echo "Configuring hosts file" >> $LOG
    cp ${HOSTS} ${HOSTS}.$(date +%Y%m%d-%H%M%S)
    IP=$(grep $CURRHOST $HOSTS | grep -v '^#' | awk '{print $1}')
    sed -i "/$CURRHOST/s/^/#/" $HOSTS
    printf '%s\t%s.%s\t%s\n' $IP $CURRHOST $DOMAIN $CURRHOST >> $HOSTS
}

configure_network_sles () {
    echo "Configuring SLES11 network file" >> $LOG
    cp ${NETWORKSLES} ${NETWORKSLES}.$(date +%Y%m%d-%H%M%S)
    sed -i '1 s/^/#/' $NETWORKSLES
    echo "$CURRHOST.$DOMAIN" >> $NETWORKSLES
    hostname -v $CURRHOST
}

configure_network () {
    echo "Configuring RHEL6 network file" >> $LOG
    cp ${NETWORK} ${NETWORK}.$(date +%Y%m%d-%H%M%S)
    sed -i 's/^HOSTNAME/#HOSTNAME/' $NETWORK
    printf 'HOSTNAME=%s.%s\n' $CURRHOST $DOMAIN >> $NETWORK 
    service network restart
}

configure_krb5 () {
    echo "Backing up kerberos config file" >> $LOG
    cp ${KRBCONF} ${KRBCONF}.$(date +%Y%m%d-%H%M%S)

    echo "Configuring kerberos" >> $LOG
    cat << EOF > ${KRBCONF}

[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 default_realm = ${REALM}
 dns_lookup_realm = true
 dns_lookup_kdc = true
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true

EOF
}

configure_krb5_rodc () {
echo "Backing up kerberos config file" >> $LOG
cp ${KRBCONF} ${KRBCONF}.$(date +%Y%m%d-%H%M%S)

echo "Configuring kerberos" >> $LOG
cat << EOF > ${KRBCONF}

[logging]
  default = FILE:/var/log/krb5libs.log
  kdc = FILE:/var/log/krb5kdc.log
  admin_server = FILE:/var/log/kadmind.log

[libdefaults]
  default_realm = ${REALM}
  dns_lookup_realm = false
  dns_lookup_kdc = false
  ticket_lifetime = 24h
  renew_lifetime = 7d
  forwardable = true

[realms]
  ${REALM} = {
    kdc = ${DOM01}.${DOMAIN}
    kdc = ${DOM02}.${DOMAIN}
  }

[domain_realm]
  ${DOMAIN} = ${REALM}
  .${DOMAIN} = ${REALM}

EOF
}

configure_smb () {
    mkdir ${SMBCACHE}
    chmod 0755 ${SMBCACHE}
    echo "Saving SAMBA config file" >> $LOG
    cp ${SMBCONF} ${SMBCONF}.$(date +%Y%m%d-%H%M%S)

    echo "Configuring SAMBA" >> $LOG

    cat << EOF > ${SMBCONF}

[global]
        workgroup = ${WRKGRP}
        client signing = yes
        client use spnego = yes
        client ldap sasl wrapping = sign
        kerberos method = secrets and keytab
        log file = /var/log/samba/%m.log
        realm = ${REALM}
        security = ads
EOF
}

configure_smb_sles () {
    echo "Saving SAMBA config file" >> $LOG
    cp ${SMBCONF} ${SMBCONF}.$(date +%Y%m%d-%H%M%S)
    echo "Configurting SAMBA" >> $LOG

    cat << EOF > ${SMBCONF}

[global]
        security = ADS
        usershare allow guests = No
        idmap gid = 10000-20000
        idmap uid = 10000-20000
        kerberos method = secrets and keytab
        realm = ${REALM}
        template homedir = /home/%U
        template shell = /bin/bash
        winbind refresh tickets = yes
	winbind offline logon = no
	winbind use default domain = yes
        workgroup = ${WRKGRP}
	passdb backend = tdbsam
EOF
}

configure_sssd () {
echo "Configuring SSSD" >> $LOG
cat << EOF > ${SSSDCONF}

[domain/${DOMAIN}]
id_provider = ad
override_shell = /bin/bash
fallback_homedir = /home/%u
enumerate = True

[sssd]
services = nss, pam
config_file_version = 2
domains = ${DOMAIN}

[nss]

[pam]

EOF

chown root:root ${SSSDCONF}
chmod 0600 ${SSSDCONF}
}

configure_sssd_rodc () {
echo "Configuring SSSD" >> $LOG
cat << EOF > ${SSSDCONF}

[domain/${DOMAIN}]
id_provider = ad
override_shell = /bin/bash
fallback_homedir = /home/%u
enumerate = True
ad_server = ${DOM01}.${DOMAIN},${DOM02}.${DOMAIN}

[sssd]
services = nss, pam
config_file_version = 2
domains = ${DOMAIN}

[nss]

[pam]

EOF

chown root:root ${SSSDCONF}
chmod 0600 ${SSSDCONF}
}

configure_pam () {
    # This needs rewriting to use better pattern matching
echo "Saving PAM configs" >> $LOG
cp ${PAMCONF} ${PAMCONF}.$(date +%Y%m%d-%H%M%S)
cp ${PAMPWCONF} ${PAMPWCONF}.$(date +%Y%m%d-%H%M%S)

echo "Configure PAM setup to work with sssd" >> $LOG
sed -i "/auth        \[success=1/d" ${PAMCONF}
sed -i "/auth        requisite     pam_succeed/d" ${PAMCONF}

sed -i "/auth        required      pam_faillock.so/a\auth        sufficient    pam_unix.so nullok try_first_pass\nauth        requisite     pam_succeed_if.so uid >= 500 quiet\nauth        sufficient    pam_sss.so use_first_pass" ${PAMCONF}
sed -i "/auth        sufficient    pam_faillock.so authsucc/a\auth        \[success=1 default=bad\]    pam_unix.so" ${PAMCONF}
sed -i "/account     sufficient    pam_succeed_if.so/a\account \[default=bad success=ok user_unknown=ignore\] pam_sss.so" ${PAMCONF}
sed -i "/password    sufficient    pam_unix.so/a\password    sufficient    pam_sss.so use_authtok" ${PAMCONF}
sed -i "/session     required      pam_limits.so/a\session     optional      pam_oddjob_mkhomedir.so skel=/etc/skel umask=0077" ${PAMCONF}
sed -i "/session     required      pam_unix.so/a\session     optional      pam_sss.so" ${PAMCONF}

sed -i "/auth        \[success=1/d" ${PAMPWCONF}
sed -i "/auth        requisite     pam_succeed/d" ${PAMPWCONF}

sed -i "/auth        required      pam_faillock.so/a\auth        sufficient    pam_unix.so nullok try_first_pass\nauth        requisite     pam_succeed_if.so uid >= 500 quiet\nauth        sufficient    pam_sss.so use_first_pass" ${PAMPWCONF}
sed -i "/auth        sufficient    pam_faillock.so authsucc/a\auth        \[success=1 default=bad\]    pam_unix.so" ${PAMPWCONF}
sed -i "/session     required      pam_limits.so/a\session     optional      pam_oddjob_mkhomedir.so skel=/etc/skel umask=0077" ${PAMPWCONF}
sed -i "/session     required      pam_unix.so/a\session     optional      pam_sss.so" ${PAMPWCONF}
}

configure_pam_sles () {
    echo "Saving PAM configs" >> $LOG
    for FILE in ${SLESPAM1} ${SLESPAM2} ${SLESPAM3} ${SLESPAM4}
    do
	cp ${FILE} ${FILE}.$(date +%Y%m%d-%H%M%S)
    done
    pam-config -a --winbind --mkhomedir --mkhomedir-umask=0077
    if [ $? != 0 ]; then
        echo "Error updating PAM configuration" | tee -a ${LOG}
    fi

#    sed -i -r -e 's/^account\s+required\s+pam_unix2.so/account\trequisite\tpam_unix2.so\naccount\tsufficient\tpam_localuser.so\naccount\trequired\tpam_winbind.so\tuse_first_pass/' ${SLESPAM1}

#    sed -i -r -e 's/^auth\s+required\s+pam_unix2.so/auth\tsufficient\tpam_unix2.so\nauth\trequired\tpam_winbind.so\tuse_first_pass/' ${SLESPAM2}

#    sed -i -r -e '/^password\s+requisite\s+pam_pwcheck.so\s+nullok\s+cracklib/i password\tsufficient\tpam_winbind.so' ${SLESPAM3}

#    sed -i -r -e '/^session\s+required\s+pam_limits.so/i session\toptional\tpam_mkhomedir.so\tumask=0077' ${SLESPAM4}
#    sed -i -r -e '/^session\s+required\s+pam_unix2.so/a session\trequired\tpam_winbind.so' ${SLESPAM4}
}


configure_oddjob () {
    echo "Saving oddjob config" >> $LOG
    cp ${ODDJCONF} ${ODDJCONF}.$(date +%Y%m%d-%H%M%S)

    echo "Configuring oddjob" >> $LOG
    sed -i "s/0002/077/g" ${ODDJCONF}

    service oddjobd restart
}

init_krb5_ticket () {
  echo "Initialising Kerberos" >> $LOG
  #echo -n ${DOMAIN_PASSWORD} | kinit ${DOMAIN_USER}
  printf %s ${DOMAIN_PASSWORD} | kinit ${DOMAIN_USER}
}

ad_join_create_keytab () {
    echo "Join RHEL Client to AD Domain" >> $LOG
	# The /etc/krb5.keytab file will be created after the following command:
    net ads join -k
	
	if [ "$(net ads testjoin -k)" != "Join is OK" ]
    then
        echo "Linux server is not Joined to the Active Directory" >> $LOG
        exit "46"
    fi
}

start_daemons () {
    echo "starting sssd and oddjobd restart" >> $LOG
    chkconfig sssd on
    chkconfig oddjobd on
    service oddjobd restart
    service sssd start
}

start_daemons_sles () {
    echo "Starting Winbind" >> $LOG
    chkconfig winbind on
    service winbind stop
    sleep 3
    service winbind start
}

start_daemons_rodc () {
    echo "starting sssd and oddjobd restart" >> $LOG
    chkconfig sssd on
    chkconfig oddjobd on
    #service oddjobd restart
    #service sssd start
}

cleanup_keytabs () {
    echo "Removing temporary keytab file for security" >> $LOG
    #/bin/rm ${TMPKEYTAB}
}

configure_nsswitch () {
    echo "Configuring nsswitch.conf" >> $LOG
    cp ${NSSCONF} ${NSSCONF}.$(date +%Y%m%d-%H%M%S)
    sed -i -r -e 's/^passwd:\s+compat$/passwd:\tcompat\twinbind/' ${NSSCONF}
    sed -i -r -e 's/^group:\s+compat$/group:\tcompat\twinbind/' ${NSSCONF}
}

# Main Script

configure_hosts

if [ -f /etc/redhat-release ]
then
    configure_network
elif [ -f /etc/SuSE-release ]
then
    configure_network_sles
fi

if [ ${OS} == 'rhel' ]; then
    if [ ${RODC} == 1 ]; then
        echo "Setting up RHEL server to join Read Only Domain Controller" >> $LOG
        configure_authconfig
        configure_krb5_rodc
        configure_smb
        configure_sssd_rodc
        configure_pam
        configure_oddjob
        start_daemons_rodc
    else
        echo "Setting up RHEL server to join Read Write Domain Controller" >> $LOG
        configure_authconfig
        configure_krb5
        configure_smb
		configure_sssd
        configure_pam
        configure_oddjob
        init_krb5_ticket
        ad_join_create_keytab
        start_daemons
        cleanup_keytabs
    fi
elif [ ${OS} == 'sles' ]; then
    if [ ${RODC} == 1 ]; then
        echo "Setting up SLES server to join Read Only Domain Controller" >> $LOG
        configure_krb5_rodc
        configure_smb_sles
        configure_nsswitch
		configure_pam_sles
		init_krb5_ticket
		ad_join_create_keytab
		start_daemons_sles
    else
        echo "Setting up SLES server to joing Read Write Domain Controller" >> $LOG
		configure_krb5
		configure_smb_sles
		configure_nsswitch
		configure_pam_sles
		init_krb5_ticket
		ad_join_create_keytab
		start_daemons_sles
    fi
fi

echo "Linux_ADDomainintegration: F---" >> $LOG
chown c-cloudauto0001:cloud $logfile
chmod 600 $logfile
exit 0