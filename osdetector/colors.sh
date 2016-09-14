#!/usr/bin/env bash

for (( i = 30; i <= 37; i++ )); 
do 
    echo -e "\e[0;"$i"m check colors"; 
done
