#!/bin/bash

# Date: 30 May 2017
# The script purpose is check password expiration for the entered first argument as username.
# If password date equal or less than 1 then,
# it will take second argument to entered to this script as new password
# And increase password life to 120 days
# If, the entered username password is changed, then script will update the root password from 3th argument
# update password expiration date
# usermod -e `date -d "30 days" +"%Y-%m-%d"` username
# Exit code "100" means: Argument count is not right.
# Exit code "99" means: Entered username is not exists
# To reset and check password use this command: passwd -w 0 -x 0 -i 0 username
# Exit code "87" means: Entered user password will not expire never.

vcount=$(echo $#)

check_args() {
    if [ "$vcount" -lt '3' ]
    then
        echo "Script requires 3 arguments."
        echo "Usage: $(basename $0) username password rootpass."
        exit 100
    fi
}

check_args

create_key_for_cloud_user () {
    uname=$(cat /etc/passwd | grep $1)
    if [ ! -n $name ]
    then
        echo "Entered username is not exists"
        echo "To create new user please use the following commands"
        echo "groupadd -g 9998 cloud"
        echo "useradd -d /home/$1 -c "Cloud-Automation-User" -g 9998 -u 9998 -s /bin/bash $1"
    else
        echo "Etnered $1 username is already exists"
        su - $1 -c "ssh-keygen -f /home/$1/.ssh/id_rsa -t rsa -N ''"
        echo "Please copy the following entry and paste to the /root/.ssh/authorized_keys file."
        cat /home/$1/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
    fi
}
#create_key_for_cloud_user $1


check_user_exists() {
  uname=$(cat /etc/passwd | grep $1 | cut -f1 -d':')
  if [ -z $uname ]
  then
     echo "Please enter valid username."
     exit 99
  else
     echo "Entered username $1 exists."
  fi
}

ssh_exec_func () {
    su - $1 -c "ssh -oStrictHostKeyChecking=no root@localhost "$2""
}
#ssh_exec_func c-cloudauto0001 "ifconfig"

check_expdate_setpass() {
  expdate=$(chage -l $1 | grep 'Password expires' | cut -f2 -d':' | awk '{print $(NF-2),$(NF-1),$NF}' | awk '{ print $2, $1, $3}' | tr -d ',')
  if [ "$expdate" = 'never' ]
  then
      echo "Password expiration is not set for this user"
      exit 87
  fi
  convexpdate=$(date -d"$expdate" +%Y%m%d)
  curdate=$(date +%Y%m%d)
  res=`expr $convexpdate - $curdate`
  if [ "$res" -le 1 ]
  then
     ssh -oStrictHostKeyChecking=no root@localhost "passwd -w 0 -x 120 -i 0 "$1""
     ssh -oStrictHostKeyChecking=no root@localhost "echo "$2" | passwd "$1" --stdin"
  else
     echo "The password age is more than one day!!!"
  fi
}

check_user_exists $1
check_expdate_setpass $1 $2

if [ "$?" = '0' ]
then
   ssh -oStrictHostKeyChecking=no root@localhost "echo $3 | passwd root --stdin"
else
   echo "The result of first script was not success!!!"
   echo "The password for 'root' user was not set!!!"
   exit "88"
fi
