#!/bin/bash

# Imports
. ~/dev/bash-scripts/functions.sh

# Checks architecture
archi=$(uname -i)
if [ "$archi" != "x86_64" ]
then
  logError "You are not on a 64 bit architecture."
  exit
fi

# Stop ongoing updates
. src/stop-updates.sh 2> /dev/null

# This variable is used to add to the apps installed in favorites
favoritesToUpdate="['org.gnome.Nautilus.desktop'"

# GIT configuration
read -p "What is your GIT name ? (Example: Jane SMITH) " gitName
read -p "What is your GIT email ? (Example: jane.smith@your-email.com) " gitEmail
read -p "What is your GIT username ? (Example: jsmith) " gitUsername

# Update
sudo apt update ; sudo apt full-upgrade -y ; sudo apt autoremove --purge -y ; sudo apt clean -y

# Installing tools
sudo apt install curl net-tools gdebi gparted unrar nodejs npm vim neovim apache2 -y
echo ""
read -p "Press <enter> key..."
echo ""

# Web browsers
OPTIONS_VALUES_WEBBROWSER=("Chrome" "Chromium" "Firefox")

for i in "${!OPTIONS_VALUES_WEBBROWSER[@]}"; do
  OPTIONS_STRING_WEBBROWSER+="${OPTIONS_VALUES_WEBBROWSER[$i]};"
done

clear
echo "You can move with ↑ and ↓. To validate an option, press <space>. Press <enter> once your selection is complete."
echo ""
echo "Select the browsers you wish to install:"

promptForMultiselect SELECTED_WEBBROWSER "$OPTIONS_STRING_WEBBROWSER"

for i in "${!SELECTED_WEBBROWSER[@]}"; do
  if [ "${SELECTED_WEBBROWSER[$i]}" == "true" ]; then
    CHECKED_WEBBROWSER+=("${OPTIONS_VALUES_WEBBROWSER[$i]}")
  fi
done

for webbrowser in "${CHECKED_WEBBROWSER[@]}"
do
  case $webbrowser in
    "Chrome")
    echo "Installing Google Chrome"
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install ./google-chrome-stable_current_amd64.deb
    # OR `sudo dpkg -i google-chrome-stable_current_amd64.deb`
    rm google-chrome-stable_current_amd64.deb
    favoritesToUpdate+=", 'google-chrome.desktop'"
    ;;

    "Chromium")
    echo "Installing Chromium"
    sudo apt install chromium-browser -y
    favoritesToUpdate+=", 'chromium-browser.desktop'"
    ;;

    "Firefox")
    echo "Installing Firefox"
    sudo apt install firefox firefox-locale-fr -y
    favoritesToUpdate+=", 'firefox.desktop'"
    ;;
  esac
done

echo ""
read -p "Press <enter> key..."
echo ""

# Utilities
OPTIONS_VALUES_UTILITIES=("Bitwarden" "Joplin" "LibreOffice" "Shutter" "Slack" "Spotify" "Terminator")

for i in "${!OPTIONS_VALUES_UTILITIES[@]}"; do
  OPTIONS_STRING_UTILITIES+="${OPTIONS_VALUES_UTILITIES[$i]};"
done

clear
echo "You can move with ↑ and ↓. To validate an option, press <space>. Press <enter> once your selection is complete."
echo ""
echo "Select the utilities you wish to install:"

promptForMultiselect SELECTED_UTILITIES "$OPTIONS_STRING_UTILITIES"

for i in "${!SELECTED_UTILITIES[@]}"; do
  if [ "${SELECTED_UTILITIES[$i]}" == "true" ]; then
    CHECKED_UTILITIES+=("${OPTIONS_VALUES_UTILITIES[$i]}")
  fi
done

for utilities in "${CHECKED_UTILITIES[@]}"
do
  case $utilities in
    "Bitwarden")
    echo "Installing Bitwarden"
    sudo snap install bitwarden
    favoritesToUpdate+=", 'bitwarden_bitwarden.desktop'"
    ;;

    "Joplin")
    echo "Installing Joplin"
    wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash
    favoritesToUpdate+=", 'appimagekit-joplin.desktop'"
    ;;

    "LibreOffice")
    echo "Installing LibreOffice"
    sudo apt install libreoffice-gnome libreoffice -y
    favoritesToUpdate+=", 'libreoffice-calc.desktop', 'libreoffice-writer.desktop'"
    ;;

    "Shutter")
    echo "Installing Shutter"
    sudo add-apt-repository ppa:shutter/ppa -y
    sudo apt install shutter -y
    favoritesToUpdate+=", 'shutter.desktop'"
    ;;

    "Slack")
    echo "Installing Slack"
    wget https://downloads.slack-edge.com/desktop-releases/linux/x64/4.38.125/slack-desktop-4.38.125-amd64.deb
    sudo apt install ./slack-desktop-4.38.125-amd64.deb
    # OR `sudo dpkg -i slack-desktop-4.38.125-amd64.deb`
    rm slack-desktop-4.38.125-amd64.deb
    favoritesToUpdate+=", 'slack.desktop'"
    ;;

    "Spotify")
    echo "Installing Spotify"
    snap install spotify
    favoritesToUpdate+=", 'spotify_spotify.desktop'"
    ;;

    "Terminator")
    echo "Installing Terminator"
    sudo apt install terminator -y
    favoritesToUpdate+=", 'terminator.desktop'"
    cp -r ./terminator/ ~/.config/
    ;;
  esac
done

echo ""
read -p "Press <enter> key..."
echo ""

# IDE
OPTIONS_VALUES_IDE=("Visual Code" "Webstorm")

for i in "${!OPTIONS_VALUES_IDE[@]}"; do
  OPTIONS_STRING_IDE+="${OPTIONS_VALUES_IDE[$i]};"
done

clear
echo "You can move with ↑ and ↓. To validate an option, press <space>. Press <enter> once your selection is complete."
echo ""
echo "Select the IDEs you wish to install:"

promptForMultiselect SELECTED_IDE "$OPTIONS_STRING_IDE"

for i in "${!SELECTED_IDE[@]}"; do
  if [ "${SELECTED_IDE[$i]}" == "true" ]; then
    CHECKED_IDE+=("${OPTIONS_VALUES_IDE[$i]}")
  fi
done

for ide in "${CHECKED_IDE[@]}"
do
  case $ide in
    "Visual Code")
    echo "Installing Visual Code"
    sudo snap install code --classic
    favoritesToUpdate+=", 'code_code.desktop'"
    ;;

    "Webstorm")
    echo "Installing Webstorm"
    sudo snap install webstorm --classic
    favoritesToUpdate+=", 'webstorm_webstorm.desktop'"
    ;;
  esac
done

echo ""
read -p "Press <enter> key..."
echo ""

# Configuration

# Git
git config credential.helper store
git config credential.helper 'cache --timeout 43200' # 12h
git config --global user.name $gitName
git config --global user.email $gitEmail
git config --global credential.username $gitUsername

wget -q https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
wget -q https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

mv git-completion.bash /home/$USER/.git-completion.bash
mv git-prompt.sh /home/$USER/.git-prompt.bash

cp dotfiles/.bash_profile /home/$USER/.bash_profile
cp dotfiles/.bashrc /home/$USER/.bashrc
cp dotfiles/.bash_aliases /home/$USER/.bash_aliases
cp dotfiles/.gitconfig /home/$USER/.gitconfig
cp dotfiles/.gitignore_global /home/$USER/.gitignore_global

# Bash
echo "if [ -f ~/.bash_profile ]; then
  . ~/.bash_profile
fi" >> /home/$USER/.bashrc

# Updates
sudo apt update ; sudo apt full-upgrade -y ; sudo apt autoremove --purge -y ; sudo apt clean -y

# Favorites
# favoritesToUpdate+=", '<example>.desktop']"
favoritesToUpdate+="]"
gsettings set org.gnome.shell favorite-apps "${favoritesToUpdate}"
dconf write /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size 38

# End of script !
echo "####################################################"
echo ""
echo "Installation done."
echo ""

read -p "Would you like to restart ? [O/n] " answerReboot
if [ "$answerReboot" != "N" ] && [ "$answerReboot" != "n" ]
then
  reboot
fi
