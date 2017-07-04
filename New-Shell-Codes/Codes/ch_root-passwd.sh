#!/bin/bash

# 2017-05-03 : initial version , michael.reichel@atos.net
# Usage: ch_root-passwd.sh <account>

SCRIPTNAME="ch_root-passwd.sh"
V="V1.0"
savedir="/home/c-cloudauto0001"
mkdir -p $savedir
logfile="$savedir/postconfig.log"

USER=$1
secret="/tmp/secret"
if [ -s $secret ] && [ "$(ls -l $secret | cut -c -10)" == "-rw-------" ] && [ -O $secret ]; then

        cat $secret | base64 --decode | sed "s/^/$USER:/" | chpasswd
	RET=$?
	rm -f $secret

	if [ $RET -ne 0 ] ; then
		echo "`date +%d.%m.%Y_%H:%M:%S` ; $SCRIPTNAME $V: chpasswd , exit-code $RET" >> $logfile
		exit $RET
	else
		echo "`date +%d.%m.%Y_%H:%M:%S` ; $SCRIPTNAME $V: chpasswd , $USER changed" >> $logfile
	fi

else
	echo "`date +%d.%m.%Y_%H:%M:%S` ; $SCRIPTNAME $V: $secret not available and/or file-modes invalid" >> $logfile
	rm -f $secret
	exit 205
fi

rm -f $secret
chmod 600 $logfile
exit 0
