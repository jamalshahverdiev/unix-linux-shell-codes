#!/bin/bash

LOG=$(basename $0 | cut -f1 -d'.').log
:> ${LOG}

Blue="\e[0;36m"
GREEN='\033[0;1;32m'
RED='\033[0;31m'
White='\033[0;37m'
Blink='\e[5m'
Normal='\e[25m'

while [ "$numtype" != "True" ]
do
        read -p "Please enter $(echo -e ${RED}number of user ${GREEN}+994): " number
        if [ "$number" -eq "$number"  2> /dev/null -a  "${#number}" = 9 ]
then
        numtype='True'
else
        echo "Entered number cannot be less than 9 or cannot be string!!!!"
fi
done

checkmysqlpass() {
    read -sp "Please enter $(echo -e ${RED}MySQL read-only ${Blue}${Blink}password ${Normal}): " pass
    until mysql -uelvin -p$pass  -e ";" 2> /dev/null
    do
       read -sp "Can't connect, please retry $(echo -e ${RED}MySQL read-only ${Blue}${Blink}password ${Normal}): " pass
    done
}

getpassandnumber() {
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
    getvars=$(mysql -uelvin -p"$pass" misdb -e "select iccid, phone_number, sale_date, closure_date, suspended, personal_code from sim where phone_number = '+994$number' ORDER BY sale_date DESC;" | grep -v iccid | head -1)
    usingstat=$(mysql -uelvin -p"$pass" misstatdb -e"select * from stat where phone_number = '+994$number' and event_succeeded = '0';" | grep -v event_type | tail -n1)
}

findnumberlogs() {
    zcat /var/log/asan-imza/mis-online-service.$1.* | grep $2 | grep -i error
}

selector

dateoflog=$(echo $usingstat | awk '{ print $3 }')


if [ -n $getvars 2> /dev/null ]
then
    echo "The $(echo -e ${GREEN}$number ${White})is not exist in database "
elif [ "$(echo $getvars | awk '{ print $5 }')" = "NULL" -a "$(echo $getvars | awk '{ print $6 }')" = "0" ]
then
    logall "Everthing is okay"
    logall "$getvars"
    logall "$usingstat"
    findnumberlogs "$dateoflog" "$number"
elif [ "$(echo $getvars | awk '{ print $5 }')" != "NULL" -a "$(echo $getvars | awk '{ print $6 }')" != "0" ]
then
    logall "Service is suspended"
else
    logall "SIM closed!!!"
fi

