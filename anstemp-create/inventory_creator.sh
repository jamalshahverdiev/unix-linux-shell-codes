#!/bin/bash

fnames=$(ls crv*)
echo '[allservers]' > hosts
rm -rf created_now

for host in $fnames
do
  echo $host >> hosts
  awk -v mytext=" ldap_mod=[ " "/^$host/"'{$0=$0mytext} 1' hosts > tmp && mv tmp hosts
  lines=$(cat $host | grep '^  - ' | awk -F "- " '{print $NF}')
  for line in $lines
  do
    awk -v mytext="\"$line\", " "/^$host/"'{$0=$0mytext} 1' hosts > tmp && mv tmp hosts
  done
done

for host in $fnames
do
  awk -v mytext="]" "/^$host/"'{$0=$0mytext} 1' hosts > tmp && mv tmp hosts
done

# Temo of AWK
#awk -v mytext=", \"EXTRA TEXT\"" '/^evvelibashlayan:/ {$0=$0mytext} 1' file

