#!/usr/bin/env bash
if [ "$#" -ne 4 ]
then
        echo "Usage: ./$(basename $0) Git_Token ProjectID Git_User Git_Password"
        exit 155
fi

folder="Projects"
mkdir -p $folder
cd $folder

subfolders=`curl -s --request GET --header "PRIVATE-TOKEN: $1" "https://domain.com/api/v4/projects/$2/repository/tree" | jq -r .[].name`
select subfolder in $subfolders
do
git init
git config core.sparsecheckout true
git remote add -f origin https://$3:$4@domain.com/devops_user/bash-codes.git
echo "$subfolder" > .git/info/sparse-checkout
git pull origin master
rm -rf .git
exit 0
done
