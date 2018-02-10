#!/bin/sh

# Nagios Monitoring
#	managed|semimanaged == active
#	unmanaged == not-active
# Usage / Expected Parameters
# ca_nagios.sh <managed|semimanaged|unmanaged> <ip-addr>
# Exit-Codes:
# 0 config successfully done
# 1 MMSA-Type not given
# 2 Nagios-User missing

V="V1.2"
SCRIPTNAME="ca_nagios.sh"

MMSA=$1
NAGIOSSRV=$2

echo="echo -e" ; export echo
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
	_log "No Option given"
	exit 1
fi

# ----
# main
# ----

_log "MMSA-Type $MMSA"

case "$MMSA" in 


	managed|semimanaged)
	# Managed-, Semi-Managed-Server

	_log "Configure, precheck for existing user"
	id nagios >> $logfile 2>&1
	if [ $? -eq 0 ] ; then
	
	        rm -f ~nagios/NaCl/NaCl.cfg 2>/dev/null
	        _log "su -  nagios -c ~nagios/NaCl/NaCl -s $NAGIOSSRV"
	        su - nagios -c "~nagios/NaCl/NaCl -s $NAGIOSSRV" >> $logfile 2>&1
	else
        _log "nagios-user is missing"
		chmod 600 $logfile
		exit 2
	fi
	
	_log "cron-job activated"
	[ -e /etc/SuSE-release ] && CRONFILE="/var/spool/cron/tabs/nagios"
	[ -e /etc/redhat-release ] && CRONFILE="/var/spool/cron/nagios"
	sed  -i '/\/home\/nagios\/NaCl\/NaCl/ s/^#.*\/home/* * * * * \/home/' $CRONFILE
	
	grep -q ^nagios /etc/cron.allow || echo "nagios" >> /etc/cron.allow
	[ -e /etc/SuSE-release ] && /etc/init.d/cron restart >> $logfile 2>&1
	[ -e /etc/redhat-release ] && /etc/init.d/crond restart >> $logfile 2>&1
	;;


	unmanaged)
	# Unmanaged Server

	_log "cron-job deactivated"
	[ -e /etc/SuSE-release ] && CRONFILE="/var/spool/cron/tabs/nagios"
	[ -e /etc/redhat-release ] && CRONFILE="/var/spool/cron/nagios"
	sed  -i '/\/home\/nagios\/NaCl\/NaCl/ s/^/#/' $CRONFILE

	[ -e /etc/SuSE-release ] && /etc/init.d/cron restart >> $logfile 2>&1
	[ -e /etc/redhat-release ] && /etc/init.d/crond restart >> $logfile 2>&1
	;;
esac

_log "F---"
chown c-cloudauto0001:cloud $logfile
chmod 600 $logfile
exit 0
