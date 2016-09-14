#!/usr/bin/env bash

# This script will rescan SCSI disk path automatically

for path in /sys/class/scsi_host/*
do
    echo "- - -" > $path/scan
done
