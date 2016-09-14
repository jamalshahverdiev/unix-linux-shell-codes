#!/bin/bash

# Author: Jamal Shahverdiev
# This is test script to compare difference between file and folder.

file="/root/bash-codes/file"
fold="/root/bash-codes/folder"
if [ -e $file ]; then
        echo "File exists"
elif [ -d $fold ]; then
        echo "Folder exists"
else
        echo "File or folder not exists"
fi

