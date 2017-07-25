#!/bin/bash
#
# Usage: configure_ADauth.sh <user> <domain> <managed|semimanaged|unmanaged>
#
# v001 - 2016-12-13 - Initial Version
# v002 - 2016-12-14 - Changed sudo section to restrict to /bin/su -
# v003 - 2016-12-14 - Changed check for already existing sudo-entry
# v004 - 2017-03-06 - Added Function log and redirected echo's to logfile
# v005 - 2017-05-29 - Corrected Syntax-Error in _log-Procedure
#
# To Do: Check to see if entry already exists in sudo configuration doesn't work

VERSION="v005"
SCRIPTNAME="Linux_ADAuthentication.sh"
logfile="/home/c-cloudauto0001/postconfig.log"
echo="echo -e"

# --------------
# Function: _log
# --------------
_log() {
        $echo "`date +%d.%m.%Y_%H:%M:%S` ; $SCRIPTNAME $VERSION: $1" >> $logfile
}

_log "Linux_ADAuthentication: S---"

usage () {
    echo -e "\n$0 <user> <domain> <managed|semimanaged|unmanaged>"
}

update_ssh () {
    #
    # Need to check for existance of the AllowUsers parameter
    # If it exists, add the user to it.  If not, create a new line
    #
    _log "Linux_ADAuthentication: Updating $SSHCONF"

    if grep -q ^AllowUsers "$SSHCONF"; then
        sed -i "/^AllowUsers/ s/$/ $WRKGRP\\\\$USER $USER/" $SSHCONF
        printf '%s updated with %s\%s\n' $SSHCONF $WRKGRP $USER
    else
        printf '#\n# Added by %s\n#\nAllowUsers\t%s\\%s\t%s\troot\n' $0 $WRKGRP $USER $USER >> $SSHCONF
	_log "Linux_ADAuthentication: $SSHCONF AllowUsers line added"
    fi
    service sshd restart
}


update_sudo () {
    #
    # Need to check for existence of 
    _log "Linux_ADAuthentication: Updating $SUDOCONF"
    # 
    # Following line should now work:
    if grep -q ^"\"$WRKGRP\\\\$USER\" ALL=/bin/su -" "$SUDOCONF"; then
        _log "Linux_ADAuthentication: User already exists in $SUDOCONF"
    else
        printf '#\n# Added by %s\n#\n"%s\%s"\tALL=/bin/su -\n%s\tALL=/bin/su -\n' $0 $WRKGRP $USER $USER >> $SUDOCONF
    fi
    # These two lines may be in the standard sudo configuration on SLES and
    # need to be removed.
    sed -i -r -e "s/^Defaults\s+targetpw/#Defaults targetpw/" $SUDOCONF
    sed -i -r -e "s/^ALL\s+/#ALL /" $SUDOCONF
  
    # The following section tests to see if the sudo configuration is valid.

    visudo -cq
    if [ $? -ne 0 ]; then
        _log "Linux_ADAuthentication: Error updating sudo file"
	exit 1
    fi
}

USER=$1
DOMAIN=$2
MODE=$3

if [ -z ${USER} ] || [ -z ${DOMAIN} ] || [ -z ${MODE} ]; then
    usage
    exit 1
fi

if [ "$MODE" != "managed" ] && [ "$MODE" != "semimanaged" ] && [ "$MODE" != "unmanaged" ]; then
    usage
    exit 1
fi

DOMAIN="$(echo $DOMAIN | tr '[A-Z]' '[a-z]')"
REALM="$(echo $DOMAIN | tr '[a-z]' '[A-Z]')"
WRKGRP=`echo ${REALM} | awk -F'.' '{print $1}'`

SSHCONF=/etc/openssh/sshd_config
SUDOCONF=/etc/sudoers

# First check for SSHCONF in the Siemens location
# If it's not there check in the default location
if [ ! -f $SSHCONF ]; then
    SSHCONF=/etc/ssh/sshd_config
    if [ ! -f $SSHCONF ]; then 
        _log "Unable to find $SSHCONF"
        exit 1
    fi
fi

if [ ! -f $SUDOCONF ]; then
    _log "Unable to find $SUDOCONF"
    exit 1
fi

if [ "$MODE" = "managed" ]; then
    _log "Add user to SSH AllowUser"
    update_ssh
fi

if [ "$MODE" = "semimanaged" ] || [ "$MODE" == "unmanaged" ]; then
    _log "Add user to SSH AllowUser and sudo configuration"
    update_ssh
    update_sudo
fi

_log "Linux_ADAuthentication: F---"
chown c-cloudauto0001:cloud $logfile
chmod 600 $logfile
