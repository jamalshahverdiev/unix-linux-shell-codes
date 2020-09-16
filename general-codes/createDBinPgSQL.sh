#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  createDBinPgSQL.sh
# 
#         USAGE:  ./createDBinPgSQL.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Jamal Shahverdiev (), jamal.shahverdiev@gmail.com
#       COMPANY:  KapitalBank LLC
#       VERSION:  1.0
#       CREATED:  03/23/2020 11:51:59 AM +04
#      REVISION:  ---
#===============================================================================

if [ $# != 4 ]
then
    echo "Usage: ./$(basename $0) dbHost dbName dbUser dbPass"
    exit 111
fi
#superPass=$(cat /etc/patroni/patroni.yml | grep password | tail -n1 | awk '{ print $2 }')
export PGPASSWORD=$superPass
superPass='GUydiudhi83d_r0ll2_geLedwieu'
dbHost=$1    # It will be haproxy lb ip
dbName=$2
dbUser=$3
dbPass=$4
PGPASSWORD=$superPass psql -h $dbHost -p 5000 -c "CREATE DATABASE $dbName;" -U postgres
PGPASSWORD=$superPass psql -h $dbHost -p 5000 -c "CREATE USER $dbUser WITH PASSWORD '$dbPass';" -U postgres
PGPASSWORD=$superPass psql -h $dbHost -p 5000 -c "GRANT ALL PRIVILEGES ON DATABASE $dbName TO $dbUser;" -U postgres
#PGPASSWORD=$superPass psql -h $dbHost -p 5000 -U postgres -c "CREATE SCHEMA alfresco AUTHORIZATION $dbUser;" $dbName

#SELECT schema_name FROM information_schema.schemata;
#DROP schema alfresco;

#SELECT schema_name FROM information_schema.schemata;
#DROP schema alfresco;
#psql -U postgres -h 10.0.80.52 -p 5000 -d db_ms_claim
