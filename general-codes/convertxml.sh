#!/usr/bin/env bash

# Author: Jamal Shhahverdiev
# This script was written for FreeSWITCH sevrer. Script does listing for /usr/local/freeswitch/conf/directory/default folder.
# and gets XML names for SIP number files. After that srcipt will append new sound file after "<variables>" line.
#
# WARNING!!!
# Script will not work with FreeBSD BASH and sed.
#

xmlfiles=`ls -r *.xml`
for file in $xmlfiles
    do
        sed -i '/<variables>/ a \\t<X-PRE-PROCESS cmd="set" data="hold_music=/usr/local/freeswitch/sounds/music/8000/fikret_amirov-men_seni_araram.wav" />' $file
    done
