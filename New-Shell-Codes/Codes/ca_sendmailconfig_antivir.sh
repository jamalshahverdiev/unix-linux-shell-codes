#!/bin/sh

# ca_sendmailconfig_antivir.sh : sendmail-config and antivirus activation / check
# V1.1 , 2016-12-05
# V1.2 , 2017-03-03 , added chown-command for $logfile
# V1.3 , 2017-04-03 , added Postfix for RedHat 7
# V1.4 , 2017-05-02 , added db-renewal to reflect new server from clone
# Usage:
# ca_sendmailconfig_antivir.sh <managed|semimanaged|unmanaged> <Mail-Gateway-IP-addr>
V="V1.4"
SCRIPTNAME="ca_sendmailconfig_antivir.sh"

MYMAILGW=""
MMSA=$1
MYMAILGW=$2

savedir="/home/c-cloudauto0001"
logfile="$savedir/postconfig.log"
echo="echo -e" ; export echo

# --------------
# Function: _log
# --------------
_log() {
         $echo "`date +%d.%m.%Y_%H:%M:%S` ; $SCRIPTNAME $V: $1" >> $logfile
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

[ -e /etc/SuSE-release ] && _add_class "sles"
grep -q "VERSION.*11"  /etc/SuSE-release 2>/dev/null && _add_class "sles11"
grep -q "VERSION.*12"  /etc/SuSE-release 2>/dev/null && _add_class "sles12"

[ -e /etc/redhat-release ] && _add_class "rhel"
grep -q "release.*6\." /etc/redhat-release 2>/dev/null && _add_class "rhel6"
grep -q "release.*7\." /etc/redhat-release 2>/dev/null && _add_class "rhel7"

_log "Sendmail: S---"


case "$MMSA" in


managed|semimanaged)

	# --------
	# sendmail
	# --------
	
	if _sysclass sles11 || _sysclass rhel6 ; then
	
		_log "Sendmail: Configure Mailgateway"
		FQDN=`dnsdomainname -a`
		SHORTNAME=`dnsdomainname -s`

		_sysclass sles11 && MYCFDIR="/usr/share/sendmail/cf"
		_sysclass rhel6 && MYCFDIR="/usr/share/sendmail-cf/cf"
		
		grep -v -e confDOMAIN_NAME -e SMART_HOST $MYCFDIR/sendmail.mc > $MYCFDIR/sendmail.mc2
		mv $MYCFDIR/sendmail.mc2 $MYCFDIR/sendmail.mc
		chmod 644 $MYCFDIR/sendmail.mc
		echo "define(\`confDOMAIN_NAME',\`${FQDN}')dnl" >> $MYCFDIR/sendmail.mc
		echo "define(\`SMART_HOST', \`smtp:${MYMAILGW}')dnl" >> $MYCFDIR/sendmail.mc
		m4 $MYCFDIR/../m4/cf.m4 $MYCFDIR/sendmail.mc >  $MYCFDIR/sendmail.cf
		cp -p $MYCFDIR/sendmail.cf /etc/mail
		chmod 644 /etc/mail/sendmail.cf
	
		cp -p $MYCFDIR/sendmail.cf /etc/mail/.sendmail.cf.ssu_config
		chmod 600 /etc/mail/.sendmail.cf.ssu_config
	
		echo $FQDN > /etc/mail/sendmail.cw
		echo $SHORTNAME >> /etc/mail/sendmail.cw
	
		_log "Sendmail: Configure relay-host $MYMAILGW"
		_log "Sendmail: Restart sendmail"
	
		_sysclass sles11 && insserv sendmail >> $logfile 2>&1
		_sysclass rhel6 && chkconfig sendmail on >> $logfile 2>&1
		/etc/init.d/sendmail restart >> $logfile 2>&1

		_log "Sendmail: F---"
	
	fi

	# -------
	# postfix
	# -------

	if _sysclass rhel7 || _sysclass sles12; then

		_log "Postfix: Configure Mailgateway"

		sed -i "/^relayhost/ s/=.*/ = $MYMAILGW/"  /etc/postfix/main.cf
		sed -i "/^myhostname/ s/=.*/ = $FQDN/" /etc/postfix/main.cf
		systemctl enable postfix >> $logfile 2>&1
		systemctl stop postfix >> $logfile 2>&1
		systemctl start postfix >> $logfile 2>&1

		_log "Postfix: F---"

	fi

	;;

esac

# ---------------------


# Antivir
# V1.0 , 2016-11-23
# V1.1 , 2016-11-24 , Changed alive criteria to check for "AgentStatus.dsmDN"
# Check state of Antivirus-Agent
# 	exit-code 0 == agent alive and state green
# 	exit-code 1 == agent not alive or state not green

logfile="$savedir/postconfig.log"
tmpfile="$savedir/ca_antivir.tmp"
RET=0

_log "Antivir: S---"


# --------------------------------
# RedHat6, RedHat7, SLES11, SLES12
# --------------------------------

if _sysclass sles11 || _sysclass sles12 || _sysclass rhel6 || _sysclass rhel7 ; then
	if [ -x /opt/ds_agent/dsa_query ] ; then

        _log "Antivir: Disconnect from ScanManager"
        /opt/ds_agent/dsa_control -r >>$logfile 2>&1

        /etc/init.d/ds_agent stop >>$logfile 2>&1
        mv /var/opt/ds_agent/dsa_core/ds_agent.db /var/opt/ds_agent/dsa_core/.ds_agent.db
        _log "Antivir: sleep 1"
        sleep 1
        /etc/init.d/ds_agent start >>$logfile 2>&1
        _log "Antivir: Logon to ScanManager"
        /opt/ds_agent/dsa_control -a dsm://155.45.167.84:4431/ "policyid:22" >>$logfile 2>&1

        _log "Antivir: Get Agent-Status"
		/opt/ds_agent/dsa_query --cmd GetAgentStatus --cmd GetAgentStatus  >> $tmpfile 2>&1
		cat $tmpfile >> $logfile
		grep -q -i "AgentStatus.agentState.*green" $tmpfile 2>/dev/null
		if [ "$?" -eq 0 ] ; then
			RET=0
		else
			RET=1
		fi
	else
		_log "Antivir: /opt/ds_agent/dsa_query not found"
		RET=1
	fi
fi



# ---------------------

_log "Antivir: F---"
chown c-cloudauto0001:cloud $logfile
chmod 600 $logfile
exit $RET
