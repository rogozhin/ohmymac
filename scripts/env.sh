#!/usr/bin/env bash

DO_MACOS_PREFS=1
DO_DEV_APPS=1
DO_APPS=1
DO_MANUAL_LIST=1
DO_ZSH_INIT=1
DO_ALL=1

SHOW_DIALOGS=1

OS="$(uname)"
HAS_SUDO_RIGHTS=1
NEED_SUDO=0
CHIP="$(uname -p)"

unsetActions(){
  DO_MACOS_PREFS=0
  DO_DEV_APPS=0
  DO_APPS=0
  DO_MANUAL_LIST=0
  DO_ZSH_INIT=0
  DO_ALL=0
}

getOpts(){
  argv=()
  while [ $# -gt 0 ]
  do
  	opt=$1
  	shift
  	case ${opt} in
  		-h|--help) # help
  			usage
  			exit 0
  			;;

      --no-dialogs)
        SHOW_DIALOGS=1
        ;;

  		--only-macos-prefs)
  			unsetActions
  			DO_MACOS_PREFS=1
  			;;
  		--only-dev-apps)
  			unsetActions
  			DO_DEV_APPS=1
  			;;
  		--only-apps)
  			unsetActions
  			DO_APPS=1
  			;;
      --only-manual-actions)
  			unsetActions
  			DO_MANUAL_LIST=1
  			;;
      --only-zsh-init)
  			unsetActions
  			DO_ZSH_INIT=1
  			;;

  		--skip-macos-prefs)
  			DO_MACOS_PREFS=0
        DO_ALL=0
  			;;
  		--skip-dev-apps)
  			DO_DEV_APPS=0
        DO_ALL=0
  			;;
  		--skip-apps)
  			DO_APPS=0
        DO_ALL=0
  			;;
      --skip-zsh-init)
  			DO_ZSH_INIT=0
  			;;

  		*)
  			if [ "${opt:0:1}" = "-" ]; then
  				echo "${txtred}${opt}: unknown option.${txtrst}"
  				usage
  				die
  			fi
  			argv+=(${opt})
  			;;
  	esac
  done
}

getOpts $*
