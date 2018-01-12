#!/bin/bash

# Author: Jamal Shahverdiev
# This script will check SmardCard daemon error.
# If error is already shown in /var/log/messages file it will restart the deaemon
# and add new lines to messages file.

ch1=`tail -n10 /var/log/messages | grep pcscd | head -n1 | awk '{ print $10 }'`
ch2=`tail -n10 /var/log/messages | grep pcscd | tail -n1 | awk '{ print $7 }'`

if [[ "$ch1" = "unavailable" ]] && [[ "$ch2" = "Error" ]]
    then
    restart xtee-batchsigner
    for i in `seq 1 10`
    do
        logger "$i Service Bacthsigner is restarted"
    done
fi

