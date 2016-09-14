#!/usr/bin/env bash

# Author: Jamal Shahverdiev
# This script supposes you have installed and configured BASH to all servers. 
# SHELL for root user is BASH on all servers and root user can remote login through ssh.
# List of IP address you must add to the iplist file.

ips=$(cat `pwd`/iplist)
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;1;32m'
Blue="\e[0;36m"

echo -e "This script will install ${RED}Apache${NC}, ${RED}PHP${NC} and ${RED}MySQL${NC} to all servers which are listed in the file ${GREEN}iplist${NC}."
echo -e "Password for ${RED}root${NC} user must be same for all servers!!!"
echo -e "But you must write ${RED}MySQL password${NC} at the installation process.."
read -sp "Please enter password for the $(echo -e ${RED}MySQL root user${NC}): " msqlpass
echo
read -sp "Please enter $(echo -e ${RED}Linux/UNIX root password${NC} for all servers): " pass

siteanddbcreds () {
    read -p "Please enter $(echo -e ${GREEN}name of site${NC}) which you want to create: " site
    read -p "Please enter $(echo -e ${RED}database${NC} name for ${GREEN}$site${NC}) site: " sitedb
    read -p "Please enter $(echo -e ${RED}username${NC} for ${GREEN}$sitedb${NC}) database: " sitedbuser
    read -sp "Please enter $(echo -e ${RED}password${NC} for ${GREEN}$sitedbuser${NC}) user: " sitedbpass
    echo
}

httpchecker () {
    if [[ $checkhttp == 80 ]]
    then
        echo -e "${GREEN}Apache${NC} web server is already installed and configured ..."
    else
        echo -e "There is ${RED}no http listener${NC} found in the server. Please check ${RED}web${NC} server. But script will continue work!!!"
    fi
}

mysqlchecker () {
    if [[ $checkmysql == 3306 ]]
    then
        echo -e "${GREEN}MySQL${NC} server is already installed and configured..."
    else
        echo -e "There is ${RED}no MySQL listener${NC} found in the server. Please check ${RED}MySQL${NC} server. But script will continue work!!!"
    fi
}

printmenu () {
    echo -e "If you want to configure ${GREEN}new vhost${NC} and create ${GREEN}MySQL database${NC} for him write ${GREEN}1${NC} and press ${RED}[Enter]${NC} button!!!"
    echo -e "If you want to ${RED}exit${NC} from script write ${GREEN}'2'${NC} and press ${RED}[Enter]${NC} button."
    read -p "Please choose: " input
}

apmsvhtemp () {
    hostname=`sshpass -p "$pass" ssh root@$ip "hostname"`
    $(sshpass -p "$pass" ssh root@$ip "echo $ip $hostname $hostname.lan >> /etc/hosts")
    $(sshpass -p "$pass" ssh root@$ip "mkdir -p /usr/local/domen /var/log/httpd/ /var/www/$site")
    if [[ $ftype = 'FreeBSD' ]]
    then
        $(cat temps/avhost.conf | sed "s/sname/$site/g" > output/$site.conf) 2> /dev/null
        $(sshpass -p "$pass" scp "output/$site.conf" root@$ip:"/usr/local/domen/") 2> /dev/null
        $(sshpass -p "$pass" scp "temps/my.cnf" root@$ip:"/etc/") 2> /dev/null
    elif [[ $ltype = 'centos' ]]
    then
        $(cat temps/cavhost.conf | sed "s/sname/$site/g" > output/$site.conf) 2> /dev/null
        $(sshpass -p "$pass" scp "output/$site.conf" root@$ip:"/usr/local/domen/") 2> /dev/null
        $(sshpass -p "$pass" scp "temps/cmy.cnf" root@$ip:"/etc/my.cnf") 2> /dev/null
    elif [[ $ltype = 'debian' ]]
    then
        $(cat temps/avhost.conf | sed "s/sname/$site/g" > output/$site.conf) 2> /dev/null
        $(sshpass -p "$pass" scp "output/$site.conf" root@$ip:"/usr/local/domen/") 2> /dev/null
    fi
    $(cat temps/index.html | sed "s/sname/unix.com/g" > output/index.html)
    $(sshpass -p "$pass" scp "output/index.html" root@$ip:"/var/www/$site/")
    $(sshpass -p "$pass" ssh root@$ip "touch /var/log/mysql.log ; chown mysql:mysql /var/log/mysql.log")
    $(cat temps/index.php | sed "s/sitedb/$sitedb/g; s/sitedbuser/$sitedbuser/g; s/sitedbpass/$sitedbpass/g" > output/index.php)
    $(sshpass -p "$pass" scp "output/index.php" root@$ip:"/var/www/$site/")
    $(cat temps/database.sql | sed "s/sitedb/$sitedb/g; s/sitedbuser/$sitedbuser/g; s/sitedbpass/$sitedbpass/g" > output/database.sql)
    $(sshpass -p "$pass" scp "output/database.sql" root@$ip:"/root/" ; sshpass -p "$pass" ssh root@$ip "mysql -uroot -p"$msqlpass" < /root/database.sql")
    echo -e "$Blue$site${NC} virtual host is configured ..."
}

debianconfiger () {
    ip=`sshpass -p "$pass" ssh root@$ip "ifconfig eth0 | grep 'inet ' | tr -s ' ' | cut -f3 -d' ' | cut -f2 -d':'"`
    apmsvhtemp 2> /dev/null
    $(sshpass -p "$pass" ssh root@$ip "echo "Include /usr/local/domen/*" >> /etc/apache2/apache2.conf") 2> /dev/null
    $(sshpass -p "$pass" ssh root@$ip "apt-get -y install php5 php5-mysql") 2> /dev/null
    $(sshpass -p "$pass" ssh root@$ip "/etc/init.d/apache2 restart") 2> /dev/null
    $(sshpass -p "$pass" ssh root@$ip "/etc/init.d/mysql restart") 2> /dev/null
}

bsdconfiger (){
    ip=`sshpass -p "$pass" ssh root@$ip "ifconfig em0 | grep 'inet ' | cut -f2 -d' '"`
    apmsvhtemp
    $(sshpass -p "$pass" scp "temps/fhttpd.conf" root@$ip:"/usr/local/etc/apache24/httpd.conf")
    $(sshpass -p "$pass" ssh root@$ip "pkg install -y mod_php56") 2> /dev/null
    $(sshpass -p "$pass" ssh root@$ip "pkg install -y php56-bz2 php56-mysql php56-mysqli php56-calendar php56-ctype php56-curl php56-dom php56-exif php56-fileinfo php56-filter php56-gd php56-gettext php56-hash php56-iconv php56-json php56-mbstring php56-mcrypt php56-openssl php56-posix php56-session php56-simplexml php56-tokenizer php56-wddx php56-xml php56-xmlreader php56-xmlwriter php56-xmlrpc php56-xsl php56-zip php56-zlib") 2> /dev/null
    $(sshpass -p "$pass" scp "temps/fphp.ini" root@$ip:"/usr/local/etc/php.ini")
    $(sshpass -p "$pass" ssh root@$ip "/usr/local/etc/rc.d/mysql-server restart") 2> /dev/null
    $(sshpass -p "$pass" ssh root@$ip "service apache24 restart") 2> /dev/null
}

centosconfiger (){
    ip=`sshpass -p "$pass" ssh root@$ip "ifconfig eth0 | grep 'inet ' | tr -s ' ' | cut -f3 -d' ' | cut -f2 -d':'"`
    apmsvhtemp 2> /dev/null
    $(sshpass -p "$pass" scp "temps/chttpd.conf" root@$ip:"/etc/httpd/conf/httpd.conf")
    $(sshpass -p "$pass" ssh root@$ip "yum -y install php php-mysql") 2> /dev/null
    $(sshpass -p "$pass" scp "temps/cphp.ini" root@$ip:"/etc/php.ini") 2> /dev/null
    $(sshpass -p "$pass" ssh root@$ip "service mysqld restart") 2> /dev/null
    $(sshpass -p "$pass" ssh root@$ip "service httpd restart") 2> /dev/null
}

for ip in $ips
do
    ltype=$(sshpass -p "$pass" ssh -o StrictHostKeyChecking=no root@$ip "cat /etc/issue | head -n1 | cut -f1 -d' ' | tr [A-Z] [a-z]" 2> /dev/null)
    ftype=$(sshpass -p "$pass" ssh -o StrictHostKeyChecking=no root@$ip "uname -a | cut -f1 -d' '" 2> /dev/null)
    echo
    if [[ $ltype = 'debian' ]]
    then
        echo -e "This is ${GREEN}Debian${NC} server!!!"
        ubupdate=$(sshpass -p "$pass" ssh root@$ip "apt-get update && apt-get -y dist-upgrade" 2> /dev/null)
        ubapinst=$(sshpass -p "$pass" ssh root@$ip "apt-get -y install apache2" 2> /dev/null)
        checkhttp=$(sshpass -p "$pass" ssh root@$ip "netstat -na|grep -i listen| grep 80 | tr ':::' '-' | tr -s ' ' | cut -f4 -d' ' | tr -d '-'" 2> /dev/null)
        httpchecker
        $(sshpass -p "$pass" ssh root@$ip "debconf-set-selections <<< 'mysql-server mysql-server/root_password password $msqlpass'" 2> /dev/null)
        $(sshpass -p "$pass" ssh root@$ip "debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $msqlpass'" 2> /dev/null)
        ubmysqlinst=$(sshpass -p "$pass" ssh root@$ip "apt-get -y install mysql-server" 2> /dev/null)
        checkmysql=$(sshpass -p "$pass" ssh root@$ip "netstat -nutlp | grep 3306 | grep -i listen | tr -s ' ' | cut -f4 -d' ' | cut -f2 -d':'" 2> /dev/null)
        mysqlchecker
        printmenu
        if [ $input -eq 1 ]
        then
            siteanddbcreds
            debianconfiger
        else
            break
        fi
    elif [[ $ltype = 'centos' ]]
    then
        echo -e "This is ${GREEN}CentOS${NC} server!!!"
        centupdate=$(sshpass -p "$pass" ssh root@$ip "yum -y upgrade" 2>/dev/null)
        centapinst=$(sshpass -p "$pass" ssh root@$ip "yum -y install httpd ; service httpd start" 2>/dev/null)
        checkhttp=$(sshpass -p "$pass" ssh root@$ip "netstat -ntl | grep ':80' | tr -s ' ' | cut -f4 -d' ' | cut -f4 -d':'" 2> /dev/null)
        httpchecker
        centmysqlinst=$(sshpass -p "$pass" ssh root@$ip "yum -y install mysql-server ; service mysqld start ; chkconfig mysqld on" 2> /dev/null)
        mysqlconf=$(sshpass -p "$pass" ssh root@$ip "echo -e '\n\n$msqlpass\n$msqlpass\n\n\n\n\n' | mysql_secure_installation" 2> /dev/null)
        checkmysql=$(sshpass -p "$pass" ssh root@$ip "netstat -nutlp | grep 3306 | grep -i listen | tr -s ' ' | cut -f4 -d' ' | cut -f2 -d':'" 2> /dev/null)
        mysqlchecker
        printmenu
        if [ $input -eq 1 ]
        then
            siteanddbcreds
            centosconfiger
        else
            break
        fi
    elif [[ $ftype = 'FreeBSD' ]]
    then
        echo -e "This is ${GREEN}FreeBSD${NC} server!!!"
        bsdupdate=$(sshpass -p "$pass" ssh root@$ip "echo y | pkg update" 2>/dev/null)
        bsdmysqlinst=$(sshpass -p "$pass" ssh root@$ip "pkg install -y mysql55-server bash ; sysrc mysql_enable="YES" ; /usr/local/etc/rc.d/mysql-server start" 2> /dev/null)
        $(sshpass -p "$pass" ssh root@$ip "echo 'fdesc /dev/fd fdescfs rw 0 0' >> /etc/fstab ; mount -a")
        mysqlconf=$(sshpass -p "$pass" ssh root@$ip "bash -c \"echo -e '\n\n$msqlpass\n$msqlpass\n\n\n\n\n' | mysql_secure_installation\"" 2> /dev/null)
        checkmysql=$(sshpass -p "$pass" ssh root@$ip "netstat -na | grep 3306 | grep -i listen | tr -s ' ' | cut -f4 -d' ' | cut -f2 -d'.'" 2> /dev/null)
	    mysqlchecker
        bsdapinst=$(sshpass -p "$pass" ssh root@$ip "pkg install -y apache24 ; sysrc apache24_enable="YES" ; /usr/local/etc/rc.d/apache24 start" 2> /dev/null)
        checkhttp=$(sshpass -p "$pass" ssh root@$ip "netstat -na | grep -i listen | grep 80 | grep tcp4 | tr -s ' ' | cut -f4 -d' ' | cut -f2 -d'.'" 2> /dev/null)
        httpchecker
        printmenu
        if [ $input -eq 1 ]
        then
            siteanddbcreds
            bsdconfiger
        else
            break
        fi
    else
        echo -e "Script cannot detect ${RED}type of UNIX/Linux${NC} server!!!"
    fi
done
