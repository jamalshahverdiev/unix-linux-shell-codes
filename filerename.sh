#!/usr/local/bin/bash

# Author: Jamal Shahverdiev
# This script convert files with empty names to underline and delete unneeded symbols.

ls | while read -r FILE
do
    mv -v "$FILE" `echo $FILE | tr ' ' '_' | tr -d '[{}(),\!]' | tr -d "\'" | tr '[A-Z]' '[a-z]' | sed 's/_-_/_/g'`
done
