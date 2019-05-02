#!/usr/bin/env bash

if [ "$#" -lt 1 ]
then
    echo "Usage: ./$(basename $0) countOfLoad"
    exit 120
fi

for count in $(seq $1)
do
    echo $count
    seq 1000000000000$count > /dev/null &
done

sleep 60 && kill -9 $(ps waux| grep se[q] | awk '{ print $2 }')
