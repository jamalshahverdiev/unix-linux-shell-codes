#!/usr/bin/env bash

ftype=$(uname -a | cut -f1 -d' ')
fvers=$(uname -a | cut -f3 -d' ' | cut -f1 -d'-')
ltype=$(uname -a | cut -f1 -d' ')
ctype=$(cat /etc/redhat-release | cut -f1 -d' ')

zonecreateFunc () {
    if [[ $# != '2' ]]
    then
        echo
        echo "   Entered argument count less than 2"
        echo "   First argument must be new domain name."
        echo "   Second argument must be DNS master configuration folder."
        echo
        exit 100
    else
        sernum=$(cat zonefile.content | grep -i serial | cut -f1 -d';' | tr -d ' ')
        upsernum=$(($sernum + 1))
        sed "s/reps1/$1/g;s~reps2~$2~g;" masterzone.file > $1.end_of_master_named.conf
        sed "s/reps1/$1/g;s~reps2~$2~g;" slavezone.file > $1.end_of_slave_named.conf
        sed "s/reps1/$1/g;s~$sernum~$upsernum~g;" zonefile.content > $1.zone
    fi
}

if [[ $ftype == "FreeBSD" ]] && [[ $fvers == "10.3" ]]
then
    echo "It is FreeBSD server."
    zonecreateFunc "vuqar.az" "/usr/local/etc/namedb"
elif [[ $ltype == "Linux" ]] && [[ $ctype == "CentOS" ]]
then
    echo "It is CentOS server"
    zonecreateFunc "vuqar.az" "/etc/namedb"
fi

