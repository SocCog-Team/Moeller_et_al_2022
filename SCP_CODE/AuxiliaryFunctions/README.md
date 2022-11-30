# AuxiliaryFunctions
Common helper functions for Matlab

# how to get started

The quickest way to get started with the dyadic interaction platform data is to first clone this repository:

0) Open a (git capable*) terminal window and navigate (cd) to the directory you want to use as the parent directory for the projects repositories

1) Add an ssh key to your github account.

2) A) Execute the following command: "git clone https://github.com/SocCog-Team/AuxiliaryFunctions"
  
3) B) Since 2021 for ssh access use:"git clone git@github.com:SocCog-Team/AuxiliaryFunctions.git"

4) Navigate (cd) in the new AuxiliaryFunctions subdiretory: e.g. "cd ./AuxiliaryFunctions" 

5) A) Execute the following command "./git_CMD_all_scp_repositories.sh clone"

6) B) Since 2121 use: "./git_CMD_all_scp_repositories.sh sshclone"

This should be all to get fresh clones of the repositories. To "update" all repositories later in one fell swoop navigate to AuxiliaryFunctions and execute "./git_CMD_all_scp_repositories.sh pull", But please note that this might fail if a repository contains local changes. In that case either commit those changes and "git push" them onto the github repository, or use "git stash" to move them out of the way quickly.



*: linux and macos should supply git as part of the default installation (or it should be available via the default package manager) for windows use https://git-scm.com/download/win to download and install the git client.
