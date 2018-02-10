#!/bin/sh

# Configure ntp
# Usage:
# ca_ntpconfig.sh <managed|semimanaged|unmanaged> <NTPSERVER1> <NTPSERVER2> <NTPSERVER3> <NTPSERVER4>

savedir="/home/c-cloudauto0001"
logfile="$savedir/postconfig.log"
echo="echo -e" ; export echo

MMSA=""
NTPSERVER1=""
NTPSERVER2=""
NTPSERVER3=""
NTPSERVER4=""

MMSA=$1
NTPSERVER1=$2
NTPSERVER2=$3
NTPSERVER3=$4
NTPSERVER4=$5

# --------------
# Function: _log
# --------------
_log() {
        $echo "`date +%d.%m.%Y_%H:%M:%S` : $1" >> $logfile
}

_log "ca_ntpconfig: S---"
_log "ca_ntpconfig: MMSA-Type $MMSA"


# ----
# main
# ----

# remove saacon-NTP-Servers from Template
sed -i '/^server /d' /etc/ntp.conf
sed -i '/155.45.163.127 /d' /etc/ntp.conf
sed -i '/155.45.163.128 /d' /etc/ntp.conf
sed -i '/155.45.163.129 /d' /etc/ntp.conf
sed -i '/155.45.163.130 /d' /etc/ntp.conf

_log "ca_ntpconfig: Configure up to four ntp-servers, ($NTPSERVER1) ($NTPSERVER2) ($NTPSERVER3) ($NTPSERVER4)"

if [ "$NTPSERVER1" != "" ] ; then
        echo "restrict $NTPSERVER1 nomodify" >> /etc/ntp.conf
        echo "server $NTPSERVER1 minpoll 6 maxpoll 12" >> /etc/ntp.conf
fi
if [ "$NTPSERVER2" != "" ] ; then
        echo "restrict $NTPSERVER2 nomodify" >> /etc/ntp.conf
        echo "server $NTPSERVER2 minpoll 6 maxpoll 12" >> /etc/ntp.conf
fi
if [ "$NTPSERVER3" != "" ] ; then
        echo "restrict $NTPSERVER3 nomodify" >> /etc/ntp.conf
        echo "server $NTPSERVER3 minpoll 6 maxpoll 12" >> /etc/ntp.conf
fi
if [ "$NTPSERVER4" != "" ] ; then
        echo "restrict $NTPSERVER4 nomodify" >> /etc/ntp.conf
        echo "server $NTPSERVER4 minpoll 6 maxpoll 12" >> /etc/ntp.conf
fi

_log "ca_ntpconfig: Restart ntpd"

updatetimebyhand () {
    $(/etc/init.d/ntp stop) 2> /dev/null
    ntpdate $1
}

# It is going to check platform type and then version.
# When version will be detected it will start ntpd and log.
if [ -f /etc/SuSE-release ]
then
    version=$(cat /etc/SuSE-release | grep -i suse | awk '{ print $(NF-1) }' | cut -f1 -d'.')
    if [ "$version" = "11" ]
    then
	    updatetimebyhand $1
        $(/etc/init.d/ntp restart) 2> /dev/null
        _log "Detected SUSE version is: 11"
    elif [ "$version" = "12" ]
    then
	    updatetimebyhand $1
        $(systemctl restart ntpd) 2> /dev/null
        _log "Detected SUSE version is: 12"
    fi
elif [ -f /etc/redhat-release ]
then
    version=$(cat /etc/redhat-release | grep -i red | awk '{ print $(NF-1) }' | cut -f1 -d'.')
    if [ "$version" = "6" ]
    then
	    updatetimebyhand $1
        $(/etc/init.d/ntpd restart) 2> /dev/null
        _log "Detected RHEL version is: 6"
    elif [ "$version" = "7" ]
    then
	    updatetimebyhand $1
        $(systemctl restart ntpd) 2> /dev/null
        _log "Detected RHEL version is: 7"
    fi
fi


_log "ca_ntpconfig: ntpq -pn"
ntpq -pn >> $logfile 2>&1

# ------------

_log "ca_ntpconfig: F---"
chown c-cloudauto0001:cloud $logfile
chmod 600 $logfile
exit 0
