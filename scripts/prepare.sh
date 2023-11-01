#!/usr/bin/env bash

checkConditions(){
  if [[ "${OS}" != "Darwin" ]]
  then
  	die "Oh! My not a Mac!"
  fi

  if [ -z "${BASH_VERSION:-}" ]
  then
  	die "Bash is required to interpret this script"
  fi

  if [ -z "$(wget -V 2>/dev/null)" ] && [ $DO_MACOS_PREFS -eq 0 ]
  then
    if [ $DO_DEV_APPS -eq 1 ] || [ $DO_DEV_APPS -eq 1 ]
    then
      die "wget is required to download applications"
    fi
  fi


  if [ -z "$(xcode-select -p 2>/dev/null)" ]
  then
  	echo "${txtred}CLT for Xcode or Xcode is required${txtrst}"
  	echo "Do 'xcode-select --install' or install Xcode"
  	exit 1
  fi
}

installBrew(){
  if [ -z "$(brew --version 2>/dev/null)" ]
  then
    printAction "Install brew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
  fi
}

installWhiptail(){
  if [ -z "$(whiptail -v 2>/dev/null)" ]
  then
    printAction "Install whiptail"
    brew install newt
  fi
}

installMas(){
  if [ -z "$(mas version 2>/dev/null)" ]
  then
    printAction "Install mas"
    brew install mas
  fi
}

init(){
  if [ -z "$(groups | grep admin)" ]
  then
  	HAS_SUDO_RIGHTS=0
  fi

  # Close any open System Preferences panes, to prevent them from overriding settings
  osascript -e 'tell application "System Preferences" to quit'

  if [ $HAS_SUDO_RIGHTS -eq 0 ] && [ $NEED_SUDO -eq 1 ]
  then
  	# Ask password and prevent to ask again
  	sudo -v
  	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
  fi

  title "Prepare environment"

  # TODO install if need
  installBrew
  installWhiptail
  installMas
}

checkConditions
init
