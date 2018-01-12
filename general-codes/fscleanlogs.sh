#!/usr/bin/env sh

# Author: Jamal Shahverdiev
# Clean log files for last day

day=`date +%d`
ym=`date +%Y-%m`
let lday="$day - 1"

rm -rf /usr/local/freeswitch/log/freeswitch.log.$ym-$lday-*
