#!/usr/bin/env bash

#Exit code "155" means required parameters are not enough
if [ "$#" -ne 4 ]
then
	echo "Usage: ./$(basename $0) Template Hostname CPU Memory"
	exit 155
fi


for range in $(seq 2 254)
do
  result=$(ping -c1 -i0.2 -w0.5 192.168.111.$range | grep received | awk '{ print $4 }')
  
  if [ "$result" = 0 ]
  then
    echo "The IP is 192.168.111.$range. Can be used. Execute Ezmomi."
    ezmomi clone --template $1 --hostname $2 --ips 192.168.111.$range --destination-folder "/Devops_ESXI/vm"  --cpus $3 --mem $4 
    exit 0
  fi
done
