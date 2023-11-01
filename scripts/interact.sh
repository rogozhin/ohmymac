#!/usr/bin/env bash

txtred=$(tput setaf 1)    # Red
txtgrn=$(tput setaf 2)    # Green
txtylw=$(tput setaf 3)    # Yellow
txtblu=$(tput setaf 4)    # Blue
txtrst=$(tput sgr0)

usage(){
echo "${txtgrn}Oh! My Mac!${txtrst}"
cat <<EOF
Lev Rogozhin (lev@rogozhin.pro)
https://github.com/rogozhin/ohmymac

usage
  $SCRIPT_NAME [options]

options
  -h --help		show this message

  --no-dialogs  Do not show dialogs

  --only-macos-prefs	Setup macos preferences and exit
  --only-dev-apps		Setup developer apps and exit
  --only-apps			Setup non-developer apps and exit
  --only-manual-actions  Show list to do manually only
  --only-zsh-init   Init zsh settings only

  --skip-macos-prefs	Do not set macos preferences
  --skip-dev-apps		Do not install developer applications
  --skip-apps			Do not install non-developer applications
  --skip-zsh-init   Do not setup zsh
EOF
}

die(){
  echo "${txtred}$*${txtrst}"
  exit 1
}
waitForKey(){
  echo ""
  echo $1
  read -rsn1
}
title(){
  echo "${txtblu}==========================${txtrst}"
  echo "${txtblu}>> $* <<${txtrst}"
}
subtitle(){
  echo "${txtblu}$*${txtrst}"
}
printAction(){
  echo "- $*"
}

showCheckboxes(){
  local ARGS=("$@")
  local TITLE=$1
  local TEXT=$2
  local CHECKBOXES=("${ARGS[@]:2}")
  local SIZE=(`stty size`)
  whiptail --nocancel --title "$TITLE" --checklist "$TEXT" ${SIZE[0]} ${SIZE[1]} $(( ${SIZE[0]} - 8 )) "${CHECKBOXES[@]}"  3>&1 1>&2 2>&3
}

isSelectedOption(){
  local OPTION=$1
  local ALL_OPTION=$2

  if [ $OPTION -eq 1 ] || [ $ALL_OPTION -eq 1 ]; then
    echo "ON"
  else
    echo "OFF"
  fi
}
