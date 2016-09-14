#!/usr/bin/env bash

# Author: Jamal Shahverdiev
# Script waits input for remote server IP and password.
# After that script will archive all files and folders in the current directory.
# Then script will upload archived files to the remote server and verify checksum with the local "`date +%F`.archived.tar.bz2"

read -p "Please enter IP address of remote server: " IP
read -sp "Please enter password of $IP server: " pass
echo 

$(tar -jcf `date +%F`.archived.tar.bz2 . 2>/dev/null)
filename=$(ls `date +%F`.archived.tar.bz2)
copytoremote=$(sshpass -p "$pass" scp `date +%F`.archived.tar.bz2 root@$IP:/root/)
sumoflocaltar=$(sha256 $filename | cut -f4 -d' ')
sumofremotetar=$(sshpass -p "$pass" ssh root@$IP "sha256sum /root/$filename | cut -f1 -d ' '")

if [[ $sumoflocaltar == $sumofremotetar ]]
then
    echo "Archive file is successfully copied to the $IP server!!!"
elif [[ $sumoflocaltar -ne $sumofremotetar ]]
then
    $copytoremote
    exit 0
fi

