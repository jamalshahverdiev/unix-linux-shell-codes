#!/bin/sh

# Clear EventLogs / System-Log-Files
SCRIPTNAME="ca_clear_event_logs.sh"
V="V1.4"

savedir="/home/c-cloudauto0001"
logfile="$savedir/postconfig.log"
echo="echo -e" ; export echo

# --------------
# Function: _log
# --------------
_log() {
        $echo "`date +%d.%m.%Y_%H:%M:%S` : $SCRIPTNAME $V: $1" >> $logfile
}


# ------------------
# Function _sysclass
# ------------------

_sysclass ()
{
        for class in $SYSCLASS
        do
                if [ "$1" == "$class" ]; then
                        return 0
                fi
        done

        return 1
}


# -------------------
# Function _add_class
# -------------------

_add_class() {

        if [ -z "$1" ]; then
                return 1
        fi

        SYSCLASS="$SYSCLASS ${1/./_}"
}

# ------------------
# Function detect OS
# ------------------
_log "S---"

[ -e /etc/SuSE-release ] && _add_class "sles"
grep -q "VERSION.*11"  /etc/SuSE-release 2>/dev/null && _add_class "sles11"
grep -q "VERSION.*12"  /etc/SuSE-release 2>/dev/null && _add_class "sles12"

[ -e /etc/redhat-release ] && _add_class "rhel"
grep -q "release.*6\." /etc/redhat-release 2>/dev/null && _add_class "rhel6"
grep -q "release.*7\." /etc/redhat-release 2>/dev/null && _add_class "rhel7"

cleantemps_sles() {
    rm -f /root/.suse_register.log 2>/dev/null
    rm -f /root/.bash_history 2>/dev/null
    echo > /var/log/zypper.log
    echo > /var/log/warn
    echo > /var/log/secure
    echo > /var/log/messages

    rm -f /var/log/warn*bz2  /var/log/messages*bz2 /var/log/mail*bz2 /var/log/acpid*bz2 /var/log/localmessages*bz2 2>/dev/null
    rm -f /var/log/boot.omsg 2>/dev/null
    # Following commented line kept for documentation purpose
    # rm -rf /tmp/* 2>/dev/null # not possible thru vRo, as it'd kill itself during runtime
    rm -f /var/log/net-snmpd.log*bz2 2>/dev/null
    rm -f /var/log/cron-*bz2 2>/dev/null
    rm -f /var/log/wtmp-*bz2 2>/dev/null
    rm -rf /var/permev/meas* 2>/dev/null
    rm -f /home/c-cloudauto0001/*.sh 2>/dev/null
    rm -f /home/c-cloudauto0001/.bash_history 2>/dev/null
	
    echo > /root/.viminfo
    echo > /root/.bash_history
}

cleantemps_rhel() {
	rm -f /root/.bash_history 2>/dev/null
	echo > /var/log/kern
	echo > /var/log/cron ; rm /var/log/cron-*
	echo > /var/log/messages ; rm -f /var/log/messages-*
	echo > /var/log/maillog ; rm -f maillog-*
	echo > /var/log/secure ; rm -f /var/log/secure-*
	echo > /var/log/spooler ; rm -f /var/log/spooler-*
	echo > /var/log/maillog ; rm -f /var/log/maillog-*
	rm -f /var/log/wtmp-* 2>/dev/null
	rm -f /var/log/yum.log-* 2>/dev/null ; echo > /var/log/yum.log
	rm -f /var/log/dmesg.old 2>/dev/null
	# Following commented line kept for documentation purpose
	# rm -rf /tmp/* 2>/dev/null # not possible thru vRo, as it'd kill itself during runtime
	rm -rf /var/permev/meas* 2>/dev/null
	rm -f /var/log/dracut.log*gz 2>/dev/null
	rm -f /home/c-cloudauto0001/*.sh 2>/dev/null
	rm -f /home/c-cloudauto0001/.bash_history 2>/dev/null
}

# -----------------
# SLES11 and SLES12
# -----------------

if _sysclass sles11 ; then
	_log "Detected SuSE Linux 11"
    cleantemps_sles
fi

if _sysclass sles12 ; then
	_log "Detected SuSE Linux 12"
    cleantemps_sles
fi

# ---------------
# RHEL6 and RHEL7
# ---------------

if _sysclass rhel6 ; then
    _log "Detected RedHat Linux 6"
    cleantemps_rhel
fi

if _sysclass rhel7 ; then
    _log "Detected RedHat Linux 7"
    cleantemps_rhel
fi

# ------------

_log "F---"
chown c-cloudauto0001:cloud $logfile
chmod 600 $logfile
exit 0
