#!/bin/sh

# Author: Jamal Shahverdiev
# This script was written for Squid and MySQL database files.

/usr/local/etc/rc.d/mysql-server stop
sleep 10

/usr/local/bin/rsync -uvroght --delete-after --backup root@10.0.0.1:/var/db/mysql /var/db/
/usr/local/etc/rc.d/mysql-server start

/usr/local/etc/rc.d/squid stop
sleep 60
/usr/local/bin/rsync -uvroght --delete-after --backup root@10.0.0.1:/usr/local/etc/squid /usr/local/etc
/usr/local/bin/rsync -uvroght --delete-after --backup root@10.0.0.1:/var/squid/cache /var/squid
/usr/local/bin/rsync -uvroght --delete-after --backup root@10.0.0.1:/usr/local/rejik /usr/local/
sleep 10
chown -R squid:squid /usr/local/rejik
sleep 3
chown -R squid:www /usr/local/rejik/_sams_banlists/
sleep 3
chown -R squid:squid /usr/local/etc/squid/
sleep 3

/usr/local/etc/rc.d/squid start
/usr/local/etc/rc.d/samba stop
sleep 10
/usr/local/bin/rsync -uvroght --delete-after --backup root@10.0.0.1:/var/db/samba /var/db/
sleep 10
/usr/local/etc/rc.d/samba start

/usr/local/etc/rc.d/sams stop
sleep 3
/usr/local/etc/rc.d/sams start
sleep 2
/usr/local/bin/rsync -uvroght --delete-after --backup root@10.0.0.1:/usr/local/etc/lightsquid /usr/local/etc
sleep 3
/usr/local/bin/rsync -uvroght --delete-after --backup root@10.0.0.1:/usr/local/www/lightsquid/report /usr/local/www/lightsquid
