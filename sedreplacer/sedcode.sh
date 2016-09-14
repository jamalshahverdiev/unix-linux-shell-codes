#!/usr/bin/env bash

dict=$(cat dict.rsp)
respfile=$(cat dbca.rsp)

#sed -i -e "s/ //g" $dict

for i in $dict
do 
    parnam=`echo $i | cut -d "=" -f1`
    sed -i -e "/$parnam/s/ //g" dbca.rsp
    sed -i -e "s/$parnam.*/$i/g; s/#$parnam.*/$i/g;" dbca.rsp
done
