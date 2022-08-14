#!/bin/bash

# Function used for multiselecting
# From Stackoverflow: https://stackoverflow.com/a/54261882/317605
prompt_for_multiselect() {
    ESC=$( printf "\033")
    cursor_blink_on()   { printf "$ESC[?25h"; }
    cursor_blink_off()  { printf "$ESC[?25l"; }
    cursor_to()         { printf "$ESC[$1;${2:-1}H"; }
    print_inactive()    { printf "$2   $1 "; }
    print_active()      { printf "$2  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()    { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }

    key_input () {
      local key
      IFS= read -rsn1 key 2>/dev/null >&2
      if [[ $key = ""      ]]; then echo enter; fi;
      if [[ $key = $'\x20' ]]; then echo space; fi;
      if [[ $key = $'\x1b' ]]; then
        read -rsn2 key
        if [[ $key = [A ]]; then echo up;    fi;
        if [[ $key = [B ]]; then echo down;  fi;
      fi
    }

    toggle_option () {
      local arr_name=$1
      eval "local arr=(\"\${${arr_name}[@]}\")"
      local option=$2
      if [[ ${arr[option]} == true ]]; then
        arr[option]=
      else
        arr[option]=true
      fi
      eval $arr_name='("${arr[@]}")'
    }

    local retval=$1
    local options
    local defaults

    IFS=';' read -r -a options <<< "$2"
    if [[ -z $3 ]]; then
      defaults=()
    else
      IFS=';' read -r -a defaults <<< "$3"
    fi
    local selected=()

    for ((i=0; i<${#options[@]}; i++)); do
      selected+=("${defaults[i]:-false}")
      printf "\n"
    done

    # Determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - ${#options[@]}))

    # Ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local active=0
    while true; do
        # Print options by overwriting the last lines
        local idx=0
        for option in "${options[@]}"; do
            local prefix="[ ]"
            if [[ ${selected[idx]} == true ]]; then
              prefix="[x]"
            fi

            cursor_to $(($startrow + $idx))
            if [ $idx -eq $active ]; then
                print_active "$option" "$prefix"
            else
                print_inactive "$option" "$prefix"
            fi
            ((idx++))
        done

        # User key control
        case `key_input` in
            space)  toggle_option selected $active;;
            enter)  break;;
            up)     ((active--));
                    if [ $active -lt 0 ]; then active=$((${#options[@]} - 1)); fi;;
            down)   ((active++));
                    if [ $active -ge ${#options[@]} ]; then active=0; fi;;
        esac
    done

    # Cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    eval $retval='("${selected[@]}")'
}

# Function used to display timely dots...
number_of_dots() {
  I=1
  while [ $I -le $1 ]
  do
    echo -n "."
    sleep 1
    I=$(( $I + 1 ))
  done
  echo ""
}

# Prerequisite

# This variable is used to add to the apps installed in favorites
favoritesToUpdate="['org.gnome.Nautilus.desktop'"

# Checks if the script has been launched with sudo command (it shouldn't)
if [ "$UID" = "0" ]
then
  echo "The script must not be launched with administrator rights (sudo)."
  exit
fi

# Checks architecture
archi=$(uname -i)
if [ "$archi" != "x86_64" ]
then
  echo "You are not on a 64 bit architecture."
  exit
fi

sudo -v

read -p "What is your GIT username ? (Example: Jane SMITH) " gitName
read -p "What is your GIT email ? (Example: jane.smith@your-email.com) " gitEmail
read -p "What is your GIT login ? (Example: jsmith) " gitLogin

# Uuncomment the next line to use "noninteractive" mode: zero interaction while installing or upgrading the system via apt.
# export DEBIAN_FRONTEND="noninteractive"

# Stop ongoing updates
. src/stop-updates.sh 2> /dev/null

# Beginning of script !

echo -n "Starting installation"
number_of_dots "3"

sleep 2

# Update
sudo apt update ; sudo apt full-upgrade -y ; sudo apt autoremove --purge -y ; sudo apt clean

# Installs

# Useful tools
sudo apt install curl net-tools git gdebi gparted unrar nodejs npm nvm vim neovim apache2 -y

# Disabling the display of error messages on the screen
sudo sed -i 's/^enabled=1$/enabled=0/' /etc/default/apport


# Web browsers
OPTIONS_VALUES_WEBBROWSER=("Firefox" "Google Chrome" "Brave" "Opera" "Chromium")

for i in "${!OPTIONS_VALUES_WEBBROWSER[@]}"; do
    OPTIONS_STRING_WEBBROWSER+="${OPTIONS_VALUES_WEBBROWSER[$i]};"
done

clear
echo "You can move with ↑ and ↓. To validate an option, press <space>. Press <enter> once your selection is complete."
echo ""
echo "Select the browser(s) you wish to install:"

prompt_for_multiselect SELECTED_WEBBROWSER "$OPTIONS_STRING_WEBBROWSER"

for i in "${!SELECTED_WEBBROWSER[@]}"; do
    if [ "${SELECTED_WEBBROWSER[$i]}" == "true" ]; then
        CHECKED_WEBBROWSER+=("${OPTIONS_VALUES_WEBBROWSER[$i]}")
    fi
done

for webbrowser in "${CHECKED_WEBBROWSER[@]}"
do
  case $webbrowser in
    "Firefox")
    echo "Installing Firefox"
    sudo apt install firefox firefox-locale-fr -y
    favoritesToUpdate+=", 'firefox.desktop'"
    ;;

    "Google Chrome")
    echo "Installing Google Chrome"
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    rm google-chrome-stable_current_amd64.deb
    favoritesToUpdate+=", 'google-chrome.desktop'"
    ;;

    "Brave")
    echo "Installing Brave"
    sudo apt install apt-transport-https curl -y
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update
    sudo apt install brave-browser -y
    favoritesToUpdate+=", 'brave-browser.desktop'"
    ;;

    "Opera")
    echo "Installing Opera"
    wget -qO - https://deb.opera.com/archive.key | sudo apt-key add -
    sudo add-apt-repository 'deb https://deb.opera.com/opera-stable/ stable non-free'
    sudo apt-get update
    sudo apt install -V opera-stable -y
    favoritesToUpdate+=", 'opera.desktop'"
    ;;

    "Chromium")
    echo "Installing Chromium"
    sudo apt install chromium-browser -y
    favoritesToUpdate+=", 'chromium-browser.desktop'"
    ;;
  esac
done


# Utilities
OPTIONS_VALUES_UTILITIES=("LibreOffice" "Terminator" "Arduino", "Insomnia")

for i in "${!OPTIONS_VALUES_UTILITIES[@]}"; do
    OPTIONS_STRING_UTILITIES+="${OPTIONS_VALUES_UTILITIES[$i]};"
done

clear
echo "You can move with ↑ and ↓. To validate an option, press <space>. Press <enter> once your selection is complete."
echo ""
echo "Select the browser(s) you wish to install:"

prompt_for_multiselect SELECTED_UTILITIES "$OPTIONS_STRING_UTILITIES"

for i in "${!SELECTED_UTILITIES[@]}"; do
    if [ "${SELECTED_UTILITIES[$i]}" == "true" ]; then
        CHECKED_UTILITIES+=("${OPTIONS_VALUES_UTILITIES[$i]}")
    fi
done

for utilities in "${CHECKED_UTILITIES[@]}"
do
  case $utilities in
    "LibreOffice")
    echo "Installing LibreOffice"
    sudo apt install libreoffice-gnome libreoffice -y
    favoritesToUpdate+=", 'libreoffice-calc.desktop', 'libreoffice-writer.desktop'"
    ;;

    "Terminator")
    echo "Installing Terminator"
    sudo apt install terminator -y
    favoritesToUpdate+=", 'terminator.desktop'"
    ;;

    "Arduino")
    echo "Installing Arduino"
    mkdir arduino
    cd arduino/
    wget https://downloads.arduino.cc/arduino-1.8.19-linux64.tar.xz
    tar -xvf ./arduino-1.8.19-linux64.tar.xz 
    cd arduino-1.8.19/
    sudo ./install.sh
    cd ../..
    rm -rf arduino/
    favoritesToUpdate+=", 'arduino-arduinoide.desktop'"
    ;;

    "Insomnia")
    echo "Installing Insomnia"
    echo "deb [trusted=yes arch=amd64] https://download.konghq.com/insomnia-ubuntu/ default all" | sudo tee -a /etc/apt/sources.list.d/insomnia.list
    wget --quiet -O - https://insomnia.rest/keys/debian-public.key.asc | sudo apt-key add -
    sudo apt-get update
    sudo apt-get install insomnia
    favoritesToUpdate+=", 'insomnia.desktop'"
    ;;
  esac
done


# IDE

OPTIONS_VALUES_IDE=("Atom" "Brackets" "Sublime text" "Visual Code" "Webstorm")

for i in "${!OPTIONS_VALUES_IDE[@]}"; do
    OPTIONS_STRING_IDE+="${OPTIONS_VALUES_IDE[$i]};"
done

clear
echo "Vous pouvez vous déplacer avec ↑ et ↓. Pour valider une option, appuyer sur <espace>. Appuyer sur <entrée> une fois votre sélection finie."
echo ""
echo "Sélectionner le(s) IDE(s) que vous souhaitez installer:"

prompt_for_multiselect SELECTED_IDE "$OPTIONS_STRING_IDE"

for i in "${!SELECTED_IDE[@]}"; do
    if [ "${SELECTED_IDE[$i]}" == "true" ]; then
        CHECKED_IDE+=("${OPTIONS_VALUES_IDE[$i]}")
    fi
done

for ide in "${CHECKED_IDE[@]}"
do
  case $ide in
    "Atom")
    echo "Installing Atom"
    sudo apt install software-properties-common apt-transport-https wget
    wget -q https://packagecloud.io/AtomEditor/atom/gpgkey -O- | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main"
    sudo apt install atom -y
    favoritesToUpdate+=", 'atom.desktop'"
    ;;

    "Brackets")
    echo "Installing Brackets"
    sudo snap install brackets --classic
    favoritesToUpdate+=", 'brackets_brackets.desktop'"
    ;;

    "Sublime text")
    echo "Installing Sublime text"
    sudo snap install sublime-text --classic
    favoritesToUpdate+=", 'sublime-text_subl.desktop'"
    ;;

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


# CONFIGURATION

# Dotfiles
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

# Git
git config --global user.name $gitName
git config --global user.email $gitEmail
git config --global credential.username $gitLogin

mkdir /home/$USER/dev
chmod o+x /home/$USER/dev

# Updates
sudo apt update ; sudo apt full-upgrade -y ; sudo apt autoremove --purge -y ; sudo apt clean -y

# Denies other users access to the main user's folder
sudo chown -R $USER:$USER /home/$USER

# Favorites
# favoritesToUpdate+=", '<example>.desktop']"
favoritesToUpdate+="]"
gsettings set org.gnome.shell favorite-apps "${favoritesToUpdate}"
dconf write /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size 38

# Configure npm globals
mkdir /home/$USER/.npm-global
npm config set prefix "/home/$USER/.npm-global"

# Install npm global
npm i -g n --silent
mkdir /home/$USER/.n
n stable
npm i -g weinre
npm i -g yo

# End of script !
echo "####################################################"
echo ""
echo "Installation terminée."
echo "Vous pouvez lancer le script de récupération des projets (3-clones.sh)"
echo ""

read -p "Would you like to restart ? [O/n] " answerReboot
if [ "$answerReboot" != "N" ] && [ "$answerReboot" != "n" ]
then
  reboot
fi