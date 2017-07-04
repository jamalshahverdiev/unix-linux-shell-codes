#!/usr/bin/env bash

read -p "Please enter minutes: " min
while [ -z $min ]
do
    read -p "Please enter minutes: " min
done

let secs=$min*60

minusoneandprint() {
    echo "$secs seconds remaining!!!"
    sleep 1
    secs=$(( $secs - 1 ))
}

while [ $secs -gt 0 ]
do
    minusoneandprint
    if [ $secs -eq 1 ]
    then
        sleep 1
        echo "At the end $secs second remaining"
        echo "You were late!!!"
        exit 0
    fi
done

