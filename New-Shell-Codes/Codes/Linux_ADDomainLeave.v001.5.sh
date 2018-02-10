#!/bin/sh
#
# Script to leave a RHEL/SLES machine from Windows Active Directory
#
# Usage - Linux_ADDomainLeave.sh <ad user> <ad password (base64 encoded)>

usage () {
   echo -e "Usage: $0 <ad user> <ad password (base64 encoded)>\n"
}

date=`date`
#LOGDIR=/tmp
LOGDIR=/home/c-cloudauto0001
#if [ ! -d "$LOGDIR" ]; then
#    echo "Log directory $LOGDIR does not exist."
#    exit 1
#fi

LOG=$LOGDIR/Linux_ADDomainLeave.log
#echo ${date} >> ${LOG}
echo "Linux_ADDomainLeave: S---" >> $LOG

OS=unknown

if [ -f /etc/redhat-release ]; then
   OS=rhel
elif [ -f /etc/SuSE-release ]; then
   OS=sles
fi

if [ $OS == 'unknown' ]; then
    echo 'Unknown operating system' | tee -a ${LOG}
    exit 1
fi

# Password should be passed through as a base64 encoded string
# to work around issues with special characters
DOMAIN_USER=$1
DOMAIN_PASSWORDtmp=$2
DOMAIN_PASSWORD=$(echo $DOMAIN_PASSWORDtmp | base64 --decode && echo)

if [ -z "$DOMAIN_USER" ]; then
   usage
   exit 1
fi

if [ -z "$DOMAIN_PASSWORD" ]; then
   usage
   exit 1
fi

# Configuration files
HOSTS=/etc/hosts
NETWORK=/etc/sysconfig/network
NETWORKSLES=/etc/HOSTNAME
KRB5KEY=/etc/krb5.keytab
SSSDCONF=/etc/sssd/sssd.conf
SMBCONF=/etc/samba/smb.conf
SLESPAM1=/etc/pam.d/common-account-pc
SLESPAM2=/etc/pam.d/common-auth-pc
SLESPAM3=/etc/pam.d/common-password-pc
SLESPAM4=/etc/pam.d/common-session-pc
CURRHOST=`hostname -s`



create_kerberos_ticket () {
    echo "Creating kerberos ticket" >> $LOG
    printf %s ${DOMAIN_PASSWORD} | kinit ${DOMAIN_USER}
}

leave_ad_domain () {
    echo "Leave RHEL Client from AD Domain" >> $LOG
    net ads leave -k
  	if [[ $? != 0 ]]; then
        echo "Domain Leave Failed" >> $LOG
	    exit 1
	fi
}

stop_daemons_rhel () {
    echo "Stopping sssd and oddjobd" >> $LOG
    chkconfig sssd off
	chkconfig oddjobd off
	service sssd stop
	service oddjobd stop
}

stop_daemons_sles () {
    echo "Stopping winbind" >> $LOG
	chkconfig winbind off
    service winbind stop
}

restore_authconfig () {
    # This assumes that a backup of authconfig was created
	# by the AD join script with the name "mybackup"
	# Create a pre-ad-leave backup just in case
	# Backups stored under /var/lib/authconfig/backup-<name>
	
	echo "Backing up authconfig" >> $LOG
	authconfig --savebackup=pre-ad-leave
	
    echo "Restoring authconfig" >> $LOG
    authconfig --restorebackup=mybackup
	if [ "$?" != "0" ]; then
	    # authconfig will return 1 if backup doesn't existk
	    echo "authconfig restore failed" >> $LOG
		exit 1
	fi
}

restore_pam_sles () {
    echo "Restoring PAM configs" >> $LOG
    for FILE in ${SLESPAM1} ${SLESPAM2} ${SLESPAM3} ${SLESPAM4}
    do
        cp ${FILE} ${FILE}.$(date +%Y%m%d-%H%M%S)
    done
    pam-config -d --winbind --mkhomedir --mkhomedir-umask=0077
    if [ $? != 0 ]; then
        echo "Error updating PAM configuration" | tee -a ${LOG}
    fi
}

configure_hosts () {
    # This should remove the host entries created by the
	# AD join script
	# CURRHOST = unqualified name from hostname -s
		
    echo "Configuring hosts file" >> $LOG
	cp ${HOSTS} ${HOSTS}.$(date +%Y%m%d-%H%M%S)
	IP=$(grep $CURRHOST $HOSTS | grep -v '^#' | awk '{print $1}')
	sed -ri "/^$IP\s+$CURRHOST/s/^/#/" $HOSTS
}

configure_hostname_rhel() {
    # This should set the hostname back
	# to the unqualified domain name
	echo "Configuring RHEL network file" >> $LOG
	cp ${NETWORK} ${NETWORK}.$(date +%Y%m%d-%H%M%S)
	sed -i 's/^HOSTNAME/#HOSTNAME/' $NETWORK
    printf 'HOSTNAME=%s\n' $CURRHOST >> $NETWORK 
    service network restart
}

configure_hostname_sles() {
    # This should set the hostname back
	# to the unqualified domain name
	echo "Configuring SLES network file" >> $LOG
    cp ${NETWORKSLES} ${NETWORKSLES}.$(date +%Y%m%d-%H%M%S)
    sed -i '1 s/^/#/' $NETWORKSLES
    echo "$CURRHOST" >> $NETWORKSLES
    hostname -v $CURRHOST
}

tidy_krb5_keytab() {
    # This moves krb5.keytab out of the way
	# Don't delete it, just in case
	echo "Moving krb5.keytab" >> $LOG
	if [ -f ${KRB5KEY} ]; then
	    mv ${KRB5KEY} ${KRB5KEY}.$(date +%Y%m%d-%H%M%S)
		kdestroy
	fi
}

tidy_sssd_conf() {
    # This moves sssd.conf out of the way
	# Don't delete it, just in case
	echo "Moving sssd.conf" >> $LOG
	if [ -f ${SSSDCONF} ]; then
	    mv ${SSSDCONF} ${SSSDCONF}.$(date +%Y%m%d-%H%M%S)
	fi
}

tidy_smb_conf() {
    # This moves smb.conf out of the way
	# Don't delete it, just in case
	echo "Moving smb.conf" >> $LOG
	if [ -f ${SMBCONF} ]; then
	    mv ${SMBCONF} ${SMBCONF}.$(date +%Y%m%d-%H%M%S)
	fi

}

configure_nsswitch () {
    # This removes winbind entries from nsswitch.conf
	#
    echo "Configuring nsswitch.conf" >> $LOG
    cp ${NSSCONF} ${NSSCONF}.$(date +%Y%m%d-%H%M%S)
    sed -i -r -e 's/^passwd:/s/winbind//' ${NSSCONF}
    sed -i -r -e 's/^group:/s/winbind//' ${NSSCONF}
}


# Main Script

if [ ${OS} == 'rhel' ]; then
    create_kerberos_ticket
	leave_ad_domain
	stop_daemons_rhel
	restore_authconfig
	configure_hostname_rhel
	tidy_sssd_conf
elif [ ${OS} == 'sles' ]; then
    create_kerberos_ticket
	leave_ad_domain
	stop_daemons_sles
	restore_pam_sles
	configure_nsswitch
	configure_hostname_sles
fi

configure_hosts
tidy_krb5_keytab
tidy_smb_conf


echo "Linux_ADDomainLeave: F---" >> $LOG
chown c-cloudauto0001:cloud $logfile
chmod 600 $logfile
exit 0
