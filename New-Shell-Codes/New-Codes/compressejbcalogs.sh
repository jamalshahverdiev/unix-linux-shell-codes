#!/usr/bin/env bash
# Script compresses files ocsp_audit.log, ejbca.log and server.log in /hdd/ and send in arxiv folder /hdd2

y=$(date -d "-2 month" +%F | cut -f1 -d -)
m=$(date -d "-2 month" +%F | cut -f2 -d -)
mh=$(date -d "-4 month" +%F | cut -f2 -d -)


monthday="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31"
declare -A LOGMAP=( [ejbca]=ejbca-logs [ocsp_audit]=ocsp_audit-logs [server]=server-logs )

logmover (){
    if [ -f /opt/jboss5/server/default/log/$1.log.$y-$m-$z ];
    then
        mkdir -p /hdd/$2/$y/$y-$m/
        mv /opt/jboss5/server/default/log/$1.log.$y-$m-$z /hdd/$2/$y/$y-$m/
        echo "   $1   Has been moved to   /hdd/$2/$y/$y-$m/ "
    else
        echo "No results found in /opt/jboss5/server/default/log/ folder for  $1 "
    fi
}

for z in $monthday
do
    for logkv in "${!LOGMAP[@]}"
    do
        logmover "$logkv" "${LOGMAP[$logkv]}"
    done
done

logarxiv () {
    firstdate=$(ls /hdd/$3-logs/$1/$1-$2/ 2> /dev/null | head -n1 | cut -f3 -d'.')
    lastdate=$(ls /hdd/$3-logs/$1/$1-$2/ 2> /dev/null | tail -n1 | cut -f3 -d'.') 
    logname=$(ls /hdd/$3-logs/$1/$1-$2/ 2> /dev/null | head -n1 | cut -f1 -d'2') 
    if [[ -z "$logname" ]] 
    then 
        echo "   WARNING:  hdd/$3-logs/$1/$1-$2/      is EMPTY OR NOT FOUND for make ARXIVE !!! "
    else    
        cd /hdd/$3-logs/$1/$1-$2
        /bin/tar -czvf $logname$firstdate--$lastdate.tar.gz $logname* --remove-file 
        sleep 2
        echo "   $logname$firstdate--$lastdate.tar.gz   arxive file has been created successfully and now start to move in /hdd2/arxive.$3.log "  
        mv $logname$firstdate--$lastdate.tar.gz /hdd2/arxive.$3.log
        echo "   $logname$firstdate--$lastdate.tar.gz   file has been moved in arxive done completely"
    fi
} 

for lognames in "${!LOGMAP[@]}"
do
    logarxiv "$y" "$mh" "$lognames"
done

