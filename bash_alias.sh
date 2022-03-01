#!/bin/bash

# Imports
. ~/dev/bash-scripts/functions.sh

# Aliases
alias miseajour='logInformation "sudo apt update" \
  && sudo apt update \
  && logInformation "sudo apt upgrade -y" \
  && sudo apt upgrade -y'
alias please='sudo'
alias reloadbashaliases='logInformation "source ~/.bashrc" \
  && source ~/.bashrc'
