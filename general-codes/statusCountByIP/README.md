##### With the `createFile.sh` we can create temporary file to check sctipt(But before that we must extract source file `tar jxf source.tar.bz2`). After taht just execute `checkCount.sh` script


input="source.txt"
while IFS= read -r line
do
    ip=$(echo $line | awk '{ print $1 }')
    if [ ! -f $ip.txt ]
    then
        openStateCount=$(cat $input | grep $ip | grep open | wc -l)
        closedStateCount=$(cat $input | grep $ip | grep closed | wc -l)
        echo "Closed state for IP $ip is repeated $closedStateCount times" > $ip.txt
        echo "Open state for IP $ip is repeated $openStateCount times" >> $ip.txt
    fi
done < "$input"

