#!/usr/bin/env bash

source ./scripts/interact.sh
source ./scripts/env.sh
source ./scripts/app.sh
source ./scripts/prepare.sh
source ./scripts/step.start.sh
source ./scripts/step.zsh.sh
source ./scripts/step.mac.sh
source ./scripts/step.devapp.sh

doFinish(){
  waitForKey "press any key to reboot"
  osascript -e 'tell application "System Events" to restart'
}
doApps(){
  title "Applications"

  # AirServer
  APP_URL="https://www.airserver.com/download/mac/latest"
  installApp "AirServer" $APP_URL

  # Zoom
  APP_URL="https://zoom.us/client/latest/Zoom.pkg"
  installApp "Zoom" $APP_URL

  # Chrome
  APP_URL="https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg"
  installApp "Chrome" $APP_URL

  # Caffeine
  APP_URL="https://github.com/IntelliScape/caffeine/releases/download/1.1.3/Caffeine.dmg"
  installApp "Caffeine" $APP_URL

  if [ -n "$(mas version 2>/dev/null)" ]
  then
    printAction "Install Telegram"
    mas install 747648890

    printAction "Install Slack"
    mas install 803453959

    printAction "Install 1Blocker"
    mas install 1365531024
  fi
}
printManualActions(){
  title "What to do manually:"
  echo "- Sarafi settings:"
  echo "  - Open Safari with all non-private windows from last session"
  echo "  - Open new window and new tab with empty page"
  echo "  - Set hompage to empty"
  echo "  - When a new tab or window opens, make it active"
  echo "  - Search engine: DuckDuckGo"
  echo "  - Show full website address"
  echo "  - Default encoding: UTF-8"
  echo "  - Show Develop menu"
  if [ $DO_DEV_APPS -eq 1 ]; then
    echo "- make iTerm local profile are default"
    echo "- sync VS Code settings"
    echo "- import TablePlus profiles"
    echo "- install Pritunl client"
  fi
}

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
  doApps
fi

if [ $DO_MANUAL_LIST -eq 1 ]; then
  printManualActions
fi

if [ $DO_MACOS_PREFS -eq 1 ]; then
  doFinish
fi
