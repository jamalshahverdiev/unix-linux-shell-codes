#1/usr/bin/env bash

#sleep 20 & PID=$! #simulate a long process

#echo "THIS MAY TAKE A WHILE, PLEASE BE PATIENT WHILE ______ IS RUNNING..."
#printf "["
##### While process is running...
#while kill -0 $PID 2> /dev/null
#do
#    printf  "â"
#    sleep 0.1
#done
#printf "] done!"

echo "Progress Active!!!"
while [ 1 ]
do
    echo "Test"
    sleep 1
done|pv >/dev/null
