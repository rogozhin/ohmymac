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

  --only-macos-prefs	Setup macos preferences and exit
  --only-dev-apps		Setup developer apps and exit
  --only-apps			Setup non-developer apps and exit
  --only-manual-actions  Show list to do manually only

  --skip-macos-prefs	Do not set macos preferences
  --skip-dev-apps		Do not install developer applications
  --skip-apps			Do not install non-developer applications
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
