#!/bin/bash

# Script to set and increase password expiration date for entered first argument.
#
# Usage - update_anyuser_pass.sh <username> <base64_encoded_password>
#
# v001 - 2016-06-18 - Initial version

# The script required is set password for entered username as first argument and password as the second argument.
# Password life for entered username will be increased to 90 days
# Update password expiration date: usermod -e `date -d "30 days" +"%Y-%m-%d"` ahmet
# To reset and check password use this command: passwd -w 0 -x 0 -i 0 username
# Exit code "100" means: Argument count is not right.
# Exit code "99" means: Entered username is not exists
# Exit code "87" means: Entered user password will not expire never.

vcount=$(echo $#)
scriptname=$(basename $0 | cut -f1 -d'.')
logfile="$(pwd)/$scriptname.log"

# This function will be used in the functions to do logging.
lognow() {
    ssh root@localhost echo -e "$(date +%d.%m.%Y\/%H:%M:%S) $0: $1" >> $logfile
}

# This function is checking the argument count. Just to be sure.
# If it will be less than 2 it will exit with code of 100
check_args() {
    if [ "$vcount" -lt '2' ]
    then
        lognow "Script requires 2 arguments. Entered count is $#"
        echo "Script requires 2 arguments."
        echo "Usage: $(basename $0) username password"
        exit 100
    fi
}

check_args

userpass=$(echo $2 | base64 --decode && echo)

# Function is going to check user name. Which is entered as first argument
check_user_exists() {
    uname=$(cat /etc/passwd | grep $1 | cut -f1 -d':')
    if [ -z "$uname" ]
    then
        echo "Please enter valid username."
        lognow "Entered user name is not exists!!!"
        exit 99
    else
        echo "Entered user name $1 exists."
        lognow "Entered user name $1 is exists"
    fi
}

# Function is going to check platform and then increase password expiration date to 90 days and set new password taken from second argument.
user_setdate_pass (){
    $(ssh -oLogLevel=Error -oStrictHostKeyChecking=no root@localhost "passwd -w 0 -x 90 -i 0 '$1'") 2> /dev/null
    lognow "Password of $1 user is increased to 90 days."
	
    if [ -f /etc/SuSE-release ] && [ "$(cat /etc/SuSE-release | grep VERSION | awk '{ print $NF }')" = "12" ]
    then
        $(ssh -oLogLevel=Error -oStrictHostKeyChecking=no root@localhost "echo -e '$userpass\n$userpass' | passwd '$1'") 2> /dev/null
        lognow "OS type is SUSE12"
        lognow "Script is set password for user: $1"
    else
        $(ssh -oLogLevel=Error -oStrictHostKeyChecking=no root@localhost "echo '$userpass' | passwd '$1' --stdin") 2> /dev/null
        lognow "OS type is SLES11 or RHEL6|7"
        lognow "Script is set password for user: $1"
    fi
}

# Function is going to check user expiration date. If output will be "never|Never" it will print out info about this.
user_check_never() {
    checknever=$(ssh -oLogLevel=Error -oStrictHostKeyChecking=no root@localhost chage -l $1 | grep -i '^Password expires' | awk '{ print $NF }')
    if [ "$checknever" = 'never' ] || [ "$checknever" = 'Never' ]
    then
        echo "Password expiration is not set for this user"
        lognow "To set password expiration for user $1 is not impossible."
        lognow "Expiration date of this users is 'Never'"
        exit 87
    fi
}

check_user_exists $1
user_check_never $1
user_setdate_pass $1 $userpass 