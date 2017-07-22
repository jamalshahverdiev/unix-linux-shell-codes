#!/bin/bash

LOG=$(basename $0 | cut -f1 -d'.').log
:> ${LOG}

Blue="\e[0;36m"
GREEN='\033[0;1;32m'
RED='\033[0;31m'
White='\033[0;37m'
Blink='\e[5m'
Normal='\e[25m'

checknumtype() {
    read -p "Please enter $(echo -e ${RED}number of user ${GREEN}+994): " number
    until [ "$number" -eq "$number" ] 2> /dev/null
    do
        echo "Entered password cannot be string. Please enter only integers!!!!"
        read -p "Please retry $(echo -e ${RED}number of user ${GREEN}+994): " number
    done
}

checknumsize() {
    read -p "Please enter $(echo -e ${RED}number of user ${GREEN}+994): " number
    while [ "${#number}" -lt 9 ]
    do
        echo "The minimal length of entered number cannot be less than 9 "
        read -p "Please retry $(echo -e ${RED}number of user ${GREEN}+994): " number
    done
}

checkmysqlpass() {
    read -sp "Please enter $(echo -e ${RED}MySQL read-only ${Blue}${Blink}password ${Normal}): " pass
    until mysql -ujamal -p$pass  -e ";" 2> /dev/null
    do
       read -sp "Can't connect, please retry $(echo -e ${RED}MySQL read-only ${Blue}${Blink}password ${Normal}): " pass
    done
}
getpassandnumber() {
    checknumsize
    checknumtype
    checkmysqlpass
    echo -e $White
}

logall(){
   echo "$(date +%d.%m.%Y_%H:%M:%S) $0 ----------------------------------------------------" | tee -a ${LOG}
   echo "$(date +%d.%m.%Y_%H:%M:%S) $0 - Started: " | tee -a ${LOG}
   echo "$(date +%d.%m.%Y_%H:%M:%S) $0 - $1" | tee -a ${LOG}
   echo "$(date +%d.%m.%Y_%H:%M:%S) $0 - Ended: " | tee -a ${LOG}
}

selector(){
    getpassandnumber
    getvars=$(mysql -ujamal -p"$pass" misdb -e "select iccid, phone_number, sale_date, closure_date, suspended, personal_code from sim where phone_number = '+994$number' ORDER BY sale_date DESC;" | grep -v iccid | head -1)
    usingstat=$(mysql -ujamal -p"$pass" misstatdb -e"select * from stat where phone_number = '+994$number' and event_succeeded = '0';" | grep -v event_type | tail -n1)
}

findnumberlogs() {
    zcat /var/log/asan-imza/mis-online-service.$1.* | grep $2 | grep -i error
}

selector

dateoflog=$(echo $usingstat | awk '{ print $3 }')

if [ "$(echo $getvars | awk '{ print $5 }')" = "NULL" -a "$(echo $getvars | awk '{ print $6 }')" = "0" ]
then
    logall "Everthing is okay"
    logall "$getvars"
    logall "$usingstat"
    findnumberlogs "$dateoflog" "516290081"
elif [ "$(echo $getvars | awk '{ print $5 }')" != "NULL" -a "$(echo $getvars | awk '{ print $6 }')" != "0" ]
then
    logall "Service is suspended"
else
    logall "SIM closed!!!"
fi
