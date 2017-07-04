#!/bin/bash

# Date: 30 May 2017
# The script purpose is set password for entered username as first argument and set third argument as root password.
# When this script will be used in the second time it will check password expiration date for the entered first argument as username.
# If password age will be equal "1" or little than "1" it will set password for first entered username and for root user.
# If password date equal or less than 1 then,
# it will take second argument to entered to this script as new password
# And increase password life to 120 days
# If, the entered username password is changed, then script will update the root password from 3th argument
# update password expiration date
# usermod -e `date -d "30 days" +"%Y-%m-%d"` ahmet
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

userpass=$(echo $2 | base64 --decode && echo)
rootpass=$(echo $3 | base64 --decode && echo)

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

userroot_setdate_pass (){
    $(ssh -oLogLevel=Error -oStrictHostKeyChecking=no root@localhost "passwd -w 0 -x 120 -i 0 '$1'") 2> /dev/null
    $(ssh -oLogLevel=Error -oStrictHostKeyChecking=no root@localhost "passwd -w 0 -x 120 -i 0 root") 2> /dev/null

    if [ -f /etc/SuSE-release ] && [ "$(cat /etc/SuSE-release | grep VERSION | awk '{ print $NF }')" = "12" ]
    then
        $(ssh -oLogLevel=Error -oStrictHostKeyChecking=no root@localhost "echo -e '$rootpass\n$rootpass' | passwd root") 2> /dev/null
        $(ssh -oLogLevel=Error -oStrictHostKeyChecking=no root@localhost "echo -e '$userpass\n$userpass' | passwd '$1'") 2> /dev/null
    else
        $(ssh -oLogLevel=Error -oStrictHostKeyChecking=no root@localhost "echo '$userpass' | passwd '$1' --stdin") 2> /dev/null
        $(ssh -oLogLevel=Error -oStrictHostKeyChecking=no root@localhost "echo '$rootpass' | passwd root --stdin") 2> /dev/null
    fi
}

check_expdate_setpass() {
  checknever=$(ssh -oLogLevel=Error -oStrictHostKeyChecking=no root@localhost chage -l $1 | grep -i '^Password expires' | awk '{ print $NF }')
  expdate=$(ssh -oLogLevel=Error -oStrictHostKeyChecking=no root@localhost chage -l $1 | grep -i '^Password expires' | awk '{ print $(NF-1),$(NF-2),$NF }' | tr -d ',')
  if [ "$checknever" = 'never' ] || [ "$checknever" = 'Never' ]
  then
      echo "Password expiration is not set for this user"
      exit 87
  fi
  convexpdate=$(date -d"$expdate" +%Y%m%d)
  curdate=$(date +%Y%m%d)
  res=`expr $convexpdate - $curdate`
  if [ "$res" -le 1 ]
  then
     userroot_setdate_pass $1 $userpass $rootpass
  else
     echo "The password age is more than one day!!!"
  fi
}

setforce_user_root_pass(){
    check_user_exists $1
    $(ssh -oLogLevel=Error -oStrictHostKeyChecking=no root@localhost "echo c-cloudauto0001 | sha256sum | cut -f1 -d' ' > /etc/c-cloudauto0001")
    userroot_setdate_pass $1 $userpass $rootpass
}

if [ -f $(ssh -oLogLevel=Error -oStrictHostKeyChecking=no root@localhost "ls /etc/c-cloudauto0001") ] && [ $(ssh -oLogLevel=Error -oStrictHostKeyChecking=no root@localhost "cat /etc/c-cloudauto0001") = "5676a5fcfb489e9b9827304b38c216f043233e5a832313ac3d997e6796faf2cc" ]
then
    echo "Password for root and $1 user is already set before"
    check_expdate_setpass $1 $userpass
else
    echo "Set $1 user and root password first time!"
    setforce_user_root_pass $1 $userpass $rootpass
fi