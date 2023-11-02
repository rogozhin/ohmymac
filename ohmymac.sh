#!/usr/bin/env bash

source ./scripts/interact.sh
source ./scripts/env.sh
source ./scripts/lib.sh
source ./scripts/prepare.sh
source ./scripts/step.start.sh
source ./scripts/step.zsh.sh
source ./scripts/step.mac.sh
source ./scripts/step.devapp.sh
source ./scripts/step.app.sh
source ./scripts/step.manual.sh
source ./scripts/step.finish.sh

echo "${txtgrn}Hello! Let's setup your new Mac!${txtrst}"

askWhatToDo

if [ $DO_DEV_APPS -eq 1 ] || [ $DO_APPS -eq 1 ]
then
  waitForKey "Be sure to log into the AppStore then press any key to start"
fi

if [ $DO_ZSH_INIT -eq 1 ]; then
  doZshInit
fi

if [ $DO_MACOS_PREFS -eq 1 ]; then
  doMacPreferences
fi

if [ $DO_DEV_APPS -eq 1 ]; then
  installDevApps
fi

if [ $DO_APPS -eq 1 ]; then
  installApps
fi

if [ $DO_MANUAL_LIST -eq 1 ]; then
  printManualActions
fi

if [ $DO_MACOS_PREFS -eq 1 ]; then
  doFinish
fi
