#!/usr/bin/env bash
if [ "$#" -ne 4 ]
then
	echo "Usage: ./$(basename $0) Git_Token ProjectID Git_User Git_Password"
        exit 155
fi


echo "The List Of Subfolders"

curl -s --request GET --header "PRIVATE-TOKEN: $1" "https://domain.com/api/v4/projects/$2/repository/tree" | jq -r .[].name

read -a list -p "Please Insert The Subfolder You Want To Pull From Repository:"

folder="Projects"
mkdir -p $folder
cd  $folder
for ((i=0;i<${#list[@]};++i))
do
	git init
	git config core.sparsecheckout true
	git remote add -f origin https://$3:$4@domain.com/devops_user/bash-codes.git
	echo "${list[i]}" > .git/info/sparse-checkout
	git pull origin master
	rm -rf .git
done
