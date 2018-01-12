#!/usr/bin/env bash

# Author: Jamal Shahverdiev
# Script will backup mysql database to the FTP server.
# For FreeBSD servers we need to change PATH variable in the /etc/crontab file as following:
# PATH=/etc:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin

DUMPFILE=`date +%Y-%m-%d-%H-%M`.dbbackup.sql
`mysqldump --databases dbbackup > /root/sql-backup/$DUMPFILE`

HOST=10.100.100.100
USER=ftpuser
PASS=ftppass

ftp -inv $HOST << EOF
user $USER $PASS

cd ftp_shares/company
lcd /root/sql-backup/
mput *.dbbackup.sql
bye
EOF
