#!/bin/sh

V="V1.5"
SCRIPTNAME="ca_os-release.sh"

echo="echo -e"
savedir="/home/c-cloudauto0001"
logfile="$savedir/postconfig.log"

# --------------
# Function: _log
# --------------
_log() {
        $echo "`date +%d.%m.%Y_%H:%M:%S` ; $SCRIPTNAME $V: $1" >> $logfile
}



# osEdition and osPatchLevel 


if [ -f /etc/SuSE-release ] ; then
        RELEASE_RPM=`rpm -qf /etc/SuSE-release`
        osPatchLEVEL="`rpm -q $RELEASE_RPM --qf "%{VERSION}\n"`"

	echo "{"
	echo -e "\t\"os\":\"SuSE Linux Enterprise Server\","
	echo -e "\t\"osVersion\":\"${osPatchLEVEL}\""
	echo "}"

	_log "SuSE Linux Enterprise Server, ${osPatchLEVEL}"
	exit 0
fi

rpm -q  redhat-release-server-6Server >/dev/null 2>&1
if [ "$?" -eq 0 ] ; then
        A=`rpm -qf /etc/redhat-release`
        osPatchLEVEL="`rpm -q $A --qf "%{RELEASE}\n" | cut -d "." -f 1-2`"

	echo "{"
	echo -e "\t\"os\":\"Red Hat Enterprise Linux Server\","
	echo -e "\t\"osVersion\":\"${osPatchLEVEL}\""
	echo "}"

	_log "Red Hat Enterprise Linux Server, ${osPatchLEVEL}"
	exit 0
fi

rpm -q  redhat-release-server-7.2 >/dev/null 2>&1
if [ "$?" -eq 0 ] ; then
        A=`rpm -qf /etc/redhat-release`
        osPatchLEVEL="`rpm -q $A --qf "%{VERSION}\n" | cut -d "." -f 1-2`"

	echo "{"
	echo -e "\t\"os\":\"Red Hat Enterprise Linux Server\","
	echo -e "\t\"osVersion\":\"${osPatchLEVEL}\""
	echo "}"

	_log "Red Hat Enterprise Linux Server, ${osPatchLEVEL}"
	exit 0
fi

rpm -q  redhat-release-server-7.3 >/dev/null 2>&1
if [ "$?" -eq 0 ] ; then
        A=`rpm -qf /etc/redhat-release`
        osPatchLEVEL="`rpm -q $A --qf "%{VERSION}\n" | cut -d "." -f 1-2`"

	echo "{"
	echo -e "\t\"os\":\"Red Hat Enterprise Linux Server\","
	echo -e "\t\"osVersion\":\"${osPatchLEVEL}\""
	echo "}"

	_log "Red Hat Enterprise Linux Server, ${osPatchLEVEL}"
	exit 0
fi


exit 1
