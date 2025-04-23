#!/bin/bash

# Imports
. ~/dev/bash-scripts/common/colors.sh

# Displays a red message to indicate an error
# Arguments:
#   $1 - Message (mandatory)
logError() {
  printf "${RED_TEXT}%s${RESET}\n" "$1"
}

# Displays a blue message to indicate an information
# Arguments:
#   $1 - Message (mandatory)
logInformation() {
  printf "${BLUE_TEXT}%s${RESET}\n" "$1"
}

# Displays a yellow message to indicate a warning
# Arguments:
#   $1 - Message (mandatory)
logWarning() {
  printf "${YELLOW_TEXT}%s${RESET}\n" "WARNING: $1"
}

# Help command - command
helpLogCommand() {
  printf "\n\t${BLUE_BOLD_TEXT}%-14s${RESET} %s" "Command:"
  printf "$1\n"
}

# Help command - description
helpLogDescription() {
  printf "\n\t${BLUE_BOLD_TEXT}%-15s${RESET}" "Description:"
  printf "$1\n"
}

# Help command - no arguments
helpLogArgumentNone() {
  printf "\n\t${BLUE_BOLD_TEXT}%-15s${RESET}" "Arguments:"
  printf -- "-\n"
}

# Help command - header of the arguments table
helpLogArgumentHeader() {
  printf "\n\t${BLUE_BOLD_TEXT}%-14s${RESET} %-15s %-15s %-15s %-20s %-50s\n" "Arguments:" "Variable" "Necessity" "Type" "Default value" "Possible values"
  printf "\t%14s %-15s %-15s %-15s %-20s %-50s\n" "" "---------------" "---------------" "---------------" "--------------------" "--------------------------------------------------"
}

# Help command - row of the arguments table
helpLogArgumentRow() {
  printf "\t%14s %-15s %-15s %-15s %-20s %-50s\n" "" "$1" "$2" "$3" "$4" "$5"
}

# Shows list of GIT branches with their description
gitBranch() {
  if [ "$1" == "--help" ]; then
    helpLogCommand "gitbranch ${WHITE_TEXT_ON_BLUE_BACKGROUND}<NO ARGUMENTS>${RESET}"
    helpLogDescription "Shows list of GIT branches with their description"
    helpLogArgumentNone
    printf "\n"
  else
    current_branch=$(git branch --show-current)
    list_of_branches=$(git branch | sed 's/^\* //' | sort)
    for branch in $list_of_branches; do
      description=$(git config branch.$branch.description)
      if [ $branch == $current_branch ]; then
        branch="${BLACK_TEXT_ON_WHITE_BACKGROUND} $branch ${RESET}"
      else
        branch="${DIM_WHITE_TEXT}$branch${RESET}"
      fi
      echo -e "    $branch\t $description${RESET}"
    done
  fi
}

# Unstashes the stash in the argument
gitPop() {
  # --help
  if [ "$1" == "--help" ]; then
    helpLogCommand "gitpop ${WHITE_TEXT_ON_BLUE_BACKGROUND}<STASH>${RESET}"
    helpLogDescription "Unstashes the stash in the argument"
    helpLogArgumentHeader
    helpLogArgumentRow "STASH" "optional" "number-ish" "0" "'0', '1', '2', ..."
    printf "\n"
  elif [ "$1" == "" ]; then
    logCommandUsed "git stash pop"
    git stash pop
  else
    logCommandUsed "git stash pop stash@{$1}"
    git stash pop stash@{$1}
  fi
}

# Displays the message "press enter key"
pressEnterKey() {
  printf "${BLUE_TEXT}Press <enter> key...${RESET}"
  read
}

# Arguments:
#   $1 - option `--hard` (optional)
MiseAJour() {
  # logInformation "sudo apt update" && sudo apt update && \
  # logInformation "sudo apt upgrade" && sudo apt upgrade -y && \
  # logInformation "sudo apt autoremove" && sudo apt autoremove -y

  logInformation "sudo apt update"
  sudo apt update

  if [ "$1" == "--hard" ]; then
    logInformation "sudo apt full-upgrade -y" && \
    sudo apt full-upgrade -y && \
    logInformation "sudo apt autoremove --purge -y" && \
    sudo apt autoremove --purge -y && \
    logInformation "sudo apt clean -y" && \
    sudo apt clean -y
  else
    logInformation "sudo apt upgrade -y" && \
    sudo apt upgrade -y && \
    logInformation "sudo apt autoremove" && \
    sudo apt autoremove -y
  fi
}

# Prompts user to chose among multiple options
# From Stackoverflow: https://stackoverflow.com/a/54261882/317605
multiSelectPrompt() {
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
