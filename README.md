# Bash scripts

Welcome to my repo of Bash scripts !

## Why this repo ?

I once had to update an installation script for newcomers at work. I found it amusing and continued working on it to adjust it to my needs and learn bash. I also found that between work and personnal computers, I would/could use the same aliases, functions and variables so I made this repo to gather everything in one place and sync them everywhere. 

## How to use it ?

You can of course simply browse my scripts, copy/paste what you find useful or use the whole repo and adjust it to your own needs.

If you want to use the repo as is, I would recommend you to do the following: 
```bash
# 1. Install GIT
sudo apt install git-all

# 2. I have based the repo to be installed in `~/dev/` so all of my scripts will point to that folder. If you don't already have one, I invite you to create a `dev` folder and go to it
mkdir ~/dev && cd ~/dev

# 3. Clone this repo
#    a. via HTTPS
git clone https://github.com/jillpouchain/bash-scripts.git
#    b. or via SSH
git clone git@github.com:jillpouchain/bash-scripts.git

# 4. Go into the repo
cd bash-scripts

# 5. Launch install script
./install.sh
```

## What are each file for ?

### bash_alias.sh

This is the file where I wrote my bash aliases.

### colors.sh

Colors variables for me to use in the terminal.

### functions.sh

Functions I find useful in my scripts.

### install.sh

This is the installation script and is used after a fresh install of Ubuntu. It will prompt the user the installation of multiple softwares and add them in the favorites bar.
This was tested on Ubuntu 20.04.
