#!/usr/bin/env bash

if [ $# != 1 ]
then
    echo "Usage: ./$(basename $0) logfile_path"
    exit
fi

logFilePath=$1

emailSender(){
  to=$1
  message=$2
  subject="AlertFrom $(basename $0)"
  mail -s "$subject" $1 <<< $2
}

while read line;
do
    case "$line" in
        *"500"* )
            errorCode=$(echo $line|awk '{ print $9 }')
            webRoutePath=$(echo $line|awk '{ print $7 }')
            emailSender 'user@domain.com' "HTTP $errorCode on $webRoutePath"
            echo 'user@domain.com' "HTTP $errorCode on $webRoutePath"
            ;;
    esac
done < <(tail -f $logFilePath)
