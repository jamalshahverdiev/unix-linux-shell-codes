#!/bin/bash

remotes='
remote1
remote2
remote3
'
gitDomain='progit.tk'
branchName='dev'
repoName='prospect'
repoFolderName='prodoc'
sourceRepoURL="git@$gitDomain:$repoFolderName/$repoName.git"
#Gitignore file should be copied here..

checkRemoteExists(){
    # Check the remote name in the file
    cat $repoFolderName/.git/config | grep $1
}

SourceRepoBranchFetchPull() {
    pushd $repoFolderName
    # git fetch RemoteRepoName RemoteBranch:LocalBranch
    git fetch $1 $2:$2 2>/dev/null

    # git pull RemoteRepoName RemoteBranch:LocalBranch
    git pull $1 $2:$2

    # git checkout LocalBranch
    git checkout $2
    popd
}

PushToDestination(){
    pushd $repoFolderName
    # git push RemoteRepoName -u LocalBranch:RemoteBranch
    #git push $1 -u $2:$2
    git push --force $1 $2:$2
    popd
}

addRemotes() {
    pushd $repoFolderName
    # git remote add RemoteRepoName git@gitlab.lan:root/RemoteRepoName.git
    git remote add $1 git@172.16.150.1:prodoc/$1.git 2>/dev/null
    popd
}

# Check folder name which will be used to store repository
if [ ! -d "$repoFolderName" -a ! -d "$repoFolderName/.git" ]
then
    mkdir $repoFolderName && pushd $repoFolderName && git init && popd
else
    echo "Git '$repoFolderName' folder and '.git' folder already exists!!!"
fi

addRemotes $sourceRepoURL
SourceRepoBranchFetchPull $sourceRepoURL $branchName

for remote in $remotes
do
    if [ -n "$(checkRemoteExists $remote)" ]
    then
        echo "The remote repository '$remote' already configured in the $repoFolderName/.git/config file!!!"
        echo "Just Syncing Local branch '$branchName' to the remote branch '$branchName'"
    else
        echo "Added new remote repository '$remote' to the $repoFolderName/.git/config file!!!"
        addRemotes $remote
    fi
    PushToDestination $remote $branchName
done

