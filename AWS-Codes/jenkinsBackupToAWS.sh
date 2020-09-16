#!/usr/bin/env bash

jenkins_home="/home/zibil/"
jenkinsBackupDir='/root/jenkinsbackups'
date=$(date +%F)
filename=jenkins_bck_$date
bucketname=jenkinsbck
files=$(ls -A $jenkins_home | egrep "^jobs$|^secrets$|^config.xml$|^jenkins.plugins.publish_over_ssh.BapSshPublisherPlugin.xml$|^credentials.xml$|^secret.key*")
echo $files

pushd $jenkins_home
tar cjf $jenkinsBackupDir/$filename.tar.bz2 $files --exclude=jenkins_bck.sh
aws s3 cp $jenkinsBackupDir/$filename.tar.bz2 s3://$bucketname/ 2>> /var/log/jenkins/jenkins_backup.err

if [ $? -eq 0 ]
then
   echo "The Backup Was Uploaded Succesfully"
   rm -rf $jenkinsBackupDir/* 2>> /dev/null
else
   echo "Failure"
fi
