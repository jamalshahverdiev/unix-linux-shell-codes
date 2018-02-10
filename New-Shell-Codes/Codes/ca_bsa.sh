#!/bin/sh

V="V1.1"
SCRIPTNAME="ca_bsa.sh"
MMSA=$1
echo="echo -e" ; export echo
SYSCLASS=""
RET=0

savedir="/home/c-cloudauto0001"
logfile="$savedir/postconfig.log"


# --------------
# Function: _log
# --------------
_log() {
        $echo "`date +%d.%m.%Y_%H:%M:%S` ; $SCRIPTNAME $V: $1" >> $logfile
}

# Initial Options
_log "S---"

if [ "$MMSA"  == "" ] ; then
	_log "No MMSA-Option given"
	exit 1
fi

_log "MMSA-Type $MMSA"

# ----
# main
# ----

case "$MMSA" in 

	managed|semimanaged)
	# Managed , Semi-Managed-Server
	_log "Start rscd, Enable daemon"
	/etc/init.d/rscd start >> $logfile 2>&1
	[ -e /etc/SuSE-release ] && insserv /etc/init.d/rscd >>$logfile 2>&1
	[ -e /etc/redhat-release ] && chkconfig rscd on >>$logfile 2>&1
	ps -ef |grep rscd |grep -v grep > /dev/null
	if [ $? -eq 0 ] ; then
	
	        RET=0
	else
        _log "rscd couldn't be started"
		RET=1
	fi
	;;

	unmanaged)
	# Un-Managed-Server
	_log "Stop rscd, Disable daemon"
	/etc/init.d/rscd stop >> $logfile 2>&1
	[ -e /etc/SuSE-release ] && insserv -r /etc/init.d/rscd >>$logfile 2>&1
	[ -e /etc/redhat-release ] && chkconfig rscd off >>$logfile 2>&1
	ps -ef |grep rscd |grep -v grep > /dev/null
	if [ $? -ne 0 ] ; then
	
	        RET=0
	else
		RET=1
	fi
	;;
esac

_log "F---"

chown c-cloudauto0001:cloud $logfile
chmod 600 $logfile
exit $RET
