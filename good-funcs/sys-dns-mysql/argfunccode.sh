#!/usr/bin/env bash

checkargs (){
    if [[ $# != '4' ]]
    then
        echo "Entered argument count less than 4"
        exit 188
    else
        echo "Entered argument count is equal to 4"
    fi
}

#checkargs 1 2 3 


mysqldbcreate (){
    if [[ $# != '4' ]]
    then
        echo 
        echo "   This function requires 4 arguments."
        echo "   First argument must be root password for MySQL root user."
        echo "   Second argument must be name for new database."
        echo "   Third argument must be user name for new database."
        echo "   Fourth argument must be password for new user name."
        echo
        exit 100
    else
        mysql -u root -p"$1" -e "CREATE database $2;"
        mysql -u root -p"$1" -e "GRANT ALL PRIVILEGES ON $2.* TO '$3'@'%' IDENTIFIED BY '$4' WITH GRANT OPTION;"
        mysql -u root -p"$1" -e "FLUSH PRIVILEGES;"
    fi
}

mysqldbcreate "freebsd" "newdb" "newuser" "^&^&UIGHJJBNK"
