#!/bin/bash

# Imports
. ~/dev/bash-scripts/colors.sh

# LOGS THE COMMAND USED MESSAGE IN TERMINAL
# Arguments:
#   $1 - Message. Mandatory.
logCommandToBeUsed() {
  if [ "$1" == "" ]; then
    logError "Missing parameter"
  else
    echo -e "${B_BLUE}The command that will be used is:${RESET} ${BG_BLUE}$1${RESET}"
  fi
}

# DISPLAYS A MESSAGE IN RED IN THE TERMINAL
# Arguments:
#   $1 - Message. Mandatory.
logError() {
  if [ "$1" == "" ]; then
    logError "Missing parameter"
  else
    echo -e "${B_RED}$1${RESET}"
  fi
}

# LOGS A HELP MESSAGE IN TERMINAL
# Arguments:
#   $1 - Message. Mandatory.
logHelp() {
  if [ "$1" == "" ]; then
    logError "Missing parameter"
  else
    echo ""
    echo -e "    $1"
    echo ""
  fi
}

# DISPLAYS A MESSAGE IN BLUE IN THE TERMINAL
# Arguments:
#   $1 - Message. Mandatory.
logInformation() {
  if [ "$1" == "" ]; then
    logError "Missing parameter"
  else
    echo -e "${B_BLUE}$1${RESET}"
  fi
}

# DISPLAYS A MESSAGE IN YELLOW IN THE TERMINAL
# Arguments:
#   $1 - Message. Mandatory.
logWarning() {
  if [ "$1" == "" ]; then
    logError "Missing parameter"
  else
    echo -e "${B_YELLOW}WARNING: $1${RESET}"
  fi
}

# PROMPTS USER TO CHOSE AMONG MULTIPLE OPTIONS
# From Stackoverflow: https://stackoverflow.com/a/54261882/317605
promptForMultiselect() {
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
