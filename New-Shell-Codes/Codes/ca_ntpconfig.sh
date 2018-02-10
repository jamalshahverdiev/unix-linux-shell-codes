#!/bin/sh

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

# ------------------
# Function _sysclass
# ------------------

#_sysclass ()
#{
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

#_add_class() {

        if [ -z "$1" ]; then
                return 1
        fi

        SYSCLASS="$SYSCLASS ${1/./_}"
}

# ------------------
# Function detect OS
# ------------------

#[ -e /etc/SuSE-release ] && _add_class "sles"
#grep -q "VERSION.*11"  /etc/SuSE-release 2>/dev/null && _add_class "sles11"

#[ -e /etc/redhat-release ] && _add_class "rhel"
#grep -q "release.*6\." /etc/redhat-release 2>/dev/null && _add_class "rhel6"

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
#[ -f /etc/redhat-release ] && /etc/init.d/ntpd restart >> $logfile 2>&1
#[ -f /etc/SuSE-release ] && /etc/init.d/ntp restart >> $logfile 2>&1

if [ -f /etc/SuSE-release ]
then
    version=$(cat /etc/SuSE-release | grep -i suse | awk '{ print $(NF-1) }' | cut -f1 -d'.')
    if [ "$version" = "11" ]
    then
        $(/etc/init.d/ntp start) 2> /dev/null
        _log "Detected SUSE version is: 11"
    elif [ "$version" = "12" ]
    then
        $(systemctl start ntpd) 2> /dev/null
        _log "Detected SUSE version is: 12"
    fi
elif [ -f /etc/redhat-release ]
then
    version=$(cat /etc/redhat-release | grep -i red | awk '{ print $(NF-1) }' | cut -f1 -d'.')
    if [ "$version" = "6" ]
    then
        $(/etc/init.d/ntpd start) 2> /dev/null
        _log "Detected RHEL version is: 6"
    elif [ "$version" = "7" ]
    then
        $(systemctl start ntpd) 2> /dev/null
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
