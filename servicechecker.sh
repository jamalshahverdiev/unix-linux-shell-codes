#!/usr/bin/env bash

# Author: Jamal Shahverdiev
# Script check service status for the remote FreeBSD and CentOS servers.

# For use "sshpass" we must install this as follows:
# For FreeBSD: pkg install -y sshpass
# For Centos: yum -y install sshpass

read -p "Please enter IP address for server: " IP
read -sp "Please enter password for $IP server: " pass
echo

chonctos=$(sshpass -p "$pass" ssh root@$IP "netstat -nutlp | grep :80 | tr ':' '\n' | grep '^80' | cut -f1 -d' '" 2>/dev/null)
chonbsd=$(sshpass -p "$pass" ssh root@$IP "sockstat -l | grep 80 | head -1 | cut -f2 -d':' | cut -f1 -d' '" 2>/dev/null)
servername=$(sshpass -p "$pass" ssh root@$IP "uname -o | cut -f'2' -d'/'")
ftype=$(sshpass -p "$pass" ssh root@$IP "uname -r | cut -f1 -d'.'")
ltype=$(sshpass -p "$pass" ssh root@$IP "cat /etc/centos-release | cut -f1 -d' '" 2>/dev/null)
ngserv="service nginx start"
ngpidfile="ls /var/run/nginx.pid"
apserv="service apache24 start"
apcosserv="service httpd start"
apcospidfile="ls /var/run/httpd/httpd.pid"
appidfile="ls /var/run/httpd.pid"
if [[ $servername == "FreeBSD" ]] && [[ $ftype == "10" ]]
then
    echo "This is FreeBSD server!!!"
    if [[ $chonbsd == "80" ]]
    then
        findwebname=$(sshpass -p "$pass" ssh root@$IP "sockstat -l | grep 80 | grep root | grep -v tcp6 | tr -s ' ' | cut -f2 -d ' '" 2>/dev/null)
        if [[ $findwebname == "httpd" ]]
        then
            echo "Apache web server is already works on FreeBSD!!!"
            exit 0
        elif [[ $findwebname == "nginx" ]]
        then
            echo "Nginx web server is already works on FreeBSD!!!"
            exit 0
        else
            echo "This script is not determined the type of WEB server!!!"
            exit 122
        fi
    else
        echo "Trying to start WEB server on FreeBSD!!!"
        startonbsd=$(sshpass -p "$pass" ssh root@$IP "$ngserv" 2>/dev/null)
        webpidbsd=$(sshpass -p "$pass" ssh root@$IP "$ngpidfile" 2>/dev/null)
        startaponbsd=$(sshpass -p "$pass" ssh root@$IP "$apserv" 2>/dev/null)
        webapidbsd=$(sshpass -p "$pass" ssh root@$IP "$appidfile" 2>/dev/null)
        sleep 1
        if [[ $webpidbsd == "/var/run/nginx.pid" ]]
        then
            echo "Nginx web server is successfully started on FreeBSD!!!"
        elif [[ $webapidbsd == "/var/run/httpd.pid" ]]
        then
            echo "Apache web server is successfully started on FreeBSD!!!"
        else
            echo "Web server isn't started on FreeBSD!!!"
        fi
    fi
elif [[ $servername == "Linux" ]] && [[ $ltype == "CentOS" ]]
then
    echo "This is CentOS server!!!"
    if [[ $chonctos -eq "80" ]]
    then
        findwebnamec=$(sshpass -p "$pass" ssh root@$IP "lsof -i :80 | grep root | tr -s ' ' | cut -f1 -d' '")
        if [[ $findwebnamec == "nginx" ]]
        then
            echo "Nginx web server is already works on CentOS!!!"
            exit 0
        elif [[ $findwebnamec == "httpd" ]]
        then
            echo "Apache web server is already works on CentOS!!!"
            exit 0
        fi
    else
        echo "Trying to start WEB server on CentOS!!!"
        startonlinux=$(sshpass -p "$pass" ssh root@$IP "$ngserv" 2>/dev/null)
        webpidlinux=$(sshpass -p "$pass" ssh root@$IP "$ngpidfile" 2>/dev/null)
        startaponcos=$(sshpass -p "$pass" ssh root@$IP "$apcosserv" 2>/dev/null)
        webapidcos=$(sshpass -p "$pass" ssh root@$IP "$apcospidfile" 2>/dev/null)
        sleep 1
        if [[ $webpidlinux == "/var/run/nginx.pid" ]]
        then
            echo "Nginx web server is successfully started on Linux!!!"
        elif [[ $webapidcos == "/var/run/httpd/httpd.pid" ]]
        then
            echo "Apache web server is successfully started!!!"
        else
            echo "Web server isn't started on CentOS!!!"
        fi
    fi
else
    echo "This is not any type of Linux/UNIX server!!!"
fi

echo "========================================================================"
