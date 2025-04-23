#!/bin/bash

# Imports
. ~/dev/bash-scripts/common/colors.sh
. ~/dev/bash-scripts/common/functions.sh

# GIT configuration
logInformation "GIT configuration"
read -p "What is your GIT name ? (Example: Jane SMITH) " userName
read -p "What is your GIT email ? (Example: jane.smith@email.com) " userEmail
git config credential.helper store
git config credential.helper 'cache --timeout 43200' # 12h
git config --global user.name $userName
git config --global user.email $userEmail

MiseAJour

# Installing tools
logInformation "Installing tools"
sudo apt install curl net-tools gdebi gparted unrar nodejs npm vim neovim apache2 libfuse2 -y
logInformation "Done"
pressEnterKey

clear

printf "You can move with ↑ and ↓. To validate an option, press <space>. Press <enter> once your selection is complete.\n\n"
printf "Select the applications you wish to install:\n"

# This variable is used to add the apps installed in favorites
appsToAddToFavoritesBar="['org.gnome.Nautilus.desktop'"

# List of applications
OPTIONS=("Bitwarden" "Chrome" "Chromium" "Firefox" "Joplin" "LibreOffice" "Shutter" "Slack" "Spotify" "Terminator" "Visual Studio Code" "Webstorm")
for i in "${!OPTIONS[@]}"; do
  OPTIONS_STRING+="${OPTIONS[$i]};"
done
multiSelectPrompt SELECTED_OPTIONS "$OPTIONS_STRING"
for i in "${!SELECTED_OPTIONS[@]}"; do
  if [ "${SELECTED_OPTIONS[$i]}" == "true" ]; then
    CHECKED_OPTIONS+=("${OPTIONS[$i]}")
  fi
done

for application in "${CHECKED_OPTIONS[@]}"
do
  case $application in
    "Bitwarden")
    logInformation "Installing Bitwarden"
    sudo snap install bitwarden
    appsToAddToFavoritesBar+=", 'bitwarden_bitwarden.desktop'"
    ;;

    "Chrome")
    logInformation "Installing Chrome"
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install ./google-chrome-stable_current_amd64.deb
    rm google-chrome-stable_current_amd64.deb
    appsToAddToFavoritesBar+=", 'google-chrome.desktop'"
    ;;

    "Chromium")
    logInformation "Installing Chromium"
    sudo apt install chromium-browser -y
    appsToAddToFavoritesBar+=", 'chromium_chromium.desktop'"
    ;;

    # TODO: add Docker desktop ?

    "Firefox")
    logInformation "Installing Firefox"
    sudo apt install firefox firefox-locale-fr -y
    appsToAddToFavoritesBar+=", 'firefox_firefox.desktop'"
    ;;

    "Joplin")
    logInformation "Installing Joplin"
    wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash
    appsToAddToFavoritesBar+=", 'appimagekit-joplin.desktop'"
    ;;

    "LibreOffice")
    logInformation "Installing LibreOffice"
    sudo apt install libreoffice-gnome libreoffice -y
    appsToAddToFavoritesBar+=", 'libreoffice-calc.desktop', 'libreoffice-writer.desktop'"
    ;;

    "Shutter")
    logInformation "Installing Shutter"
    sudo add-apt-repository ppa:shutter/ppa -y
    sudo apt install shutter -y
    appsToAddToFavoritesBar+=", 'shutter.desktop'"
    ;;

    "Slack")
    logInformation "Installing Slack"
    wget https://downloads.slack-edge.com/desktop-releases/linux/x64/4.38.125/slack-desktop-4.38.125-amd64.deb
    sudo apt install ./slack-desktop-4.38.125-amd64.deb
    rm slack-desktop-4.38.125-amd64.deb
    appsToAddToFavoritesBar+=", 'slack.desktop'"
    ;;

    "Spotify")
    logInformation "Installing Spotify"
    snap install spotify
    appsToAddToFavoritesBar+=", 'spotify_spotify.desktop'"
    ;;

    "Terminator")
    logInformation "Installing Terminator"
    sudo apt install terminator -y
    appsToAddToFavoritesBar+=", 'terminator.desktop'"
    cp -r ./terminator/ ~/.config/
    ;;

    "Visual Studio Code")
    logInformation "Installing Visual Studio Code"
    sudo snap install code --classic
    appsToAddToFavoritesBar+=", 'code_code.desktop'"
    ;;

    "Webstorm")
    logInformation "Installing Webstorm"
    sudo snap install webstorm --classic
    appsToAddToFavoritesBar+=", 'webstorm_webstorm.desktop'"
    ;;
  esac
done

pressEnterKey

# Configuration

# cp dotfiles/.bash_profile /home/$USER/.bash_profile
# cp dotfiles/.bashrc /home/$USER/.bashrc
# cp dotfiles/.bash_aliases /home/$USER/.bash_aliases
# cp dotfiles/.gitconfig /home/$USER/.gitconfig
# cp dotfiles/.gitignore_global /home/$USER/.gitignore_global

MiseAJour --hard

# Add applications to favorites
appsToAddToFavoritesBar+="]"
gsettings set org.gnome.shell favorite-apps "${appsToAddToFavoritesBar}"

# End of script !
logInformation "Installation done"

read -p "Would you like to restart ? [Y/n] " answerReboot
if [ "$answerReboot" != "N" ] && [ "$answerReboot" != "n" ]
then
  reboot
fi
