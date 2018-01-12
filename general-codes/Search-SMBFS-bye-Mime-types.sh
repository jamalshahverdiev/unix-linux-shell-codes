#!/usr/local/bin/bash

for i in /mnt/storage/SAMBA/*
do
    [ x"$(file --mime -b "$i")" != application/x-dosexec ] && echo rm "$i"
done