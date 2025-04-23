#!/bin/bash

# Imports
. ~/dev/bash-scripts/common/functions.sh

# Aliases
alias miseajour='MiseAJour'
alias please='sudo'
alias reloadbashrc='logInformation "source ~/.bashrc" && source ~/.bashrc'

# Git aliases
alias gitbranch='gitBranch'
alias gitlog='git log --graph --format=format:"%C(dim white)%h%C(reset)    %C(white)%s%C(reset) %C(dim white)(%an %ar)%C(reset)" --color -10'
alias gitpop='gitPop'