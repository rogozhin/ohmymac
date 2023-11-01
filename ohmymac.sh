#!/usr/bin/env bash

source ./scripts/interact.sh
source ./scripts/env.sh
source ./scripts/prepare.sh
source ./scripts/step.start.sh
source ./scripts/step.zsh.sh
source ./scripts/step.mac.sh

installBrewDevApps(){
  printAction "Install wget"
  brew install wget
  printAction "Install mc"
  brew install mc
  printAction "Install redis"
  brew install redis
  brew services start redis

  printAction "Install postgres"
  brew install postgres
  brew services start postgres
  mkdir -p ~/Library/LaunchAgents
  ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
  launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
}

installApp(){
  APP_NAME=$1
  APP_URL=$2
  TARGET_PATH="/Applications"

  rm -rf ./tmp
  mkdir -p ./tmp

  printAction "Install ${APP_NAME}"
  wget --directory-prefix="./tmp/" --content-disposition ${APP_URL}
  FILE_NAME=$(ls ./tmp)
  if [[ "${FILE_NAME}" =~ ".dmg?" ]]; then
    CLEAN_FILE_NAME=${FILE_NAME%%\?*}
    mv ./tmp/$FILE_NAME ./tmp/$CLEAN_FILE_NAME
    FILE_NAME=$CLEAN_FILE_NAME
  fi
  FILE_EXT=${FILE_NAME##*.}

  if [ "${FILE_EXT}" == "dmg" ]; then
    VOLUME=$(hdiutil attach -nobrowse "./tmp/${FILE_NAME}" |
      awk 'END {$1=$2=""; gsub(/^ +| +$/,""); print $0}'; exit ${PIPESTATUS[0]})
    APP_PATH=$(ls "${VOLUME}" | grep .app)
    (rsync -a "${VOLUME}/${APP_PATH}" "${TARGET_PATH}"; SYNCED=$?
      (hdiutil detach -force -quiet "$VOLUME" || exit $?) && exit "$SYNCED")
  fi
  if [ "${FILE_EXT}" == "zip" ]; then
    unzip -qq -d ./tmp "./tmp/${FILE_NAME}"
    APP_PATH=$(ls ./tmp | grep -E "(\.app|\.pkg)$")
    APP_EXT=${APP_PATH##*.}
    if [ "${APP_EXT}" == "app" ]; then
      rsync -a "./tmp/${APP_PATH}" "${TARGET_PATH}"
    fi
    if [ "${APP_EXT}" == "pkg" ]; then
      installer -pkg "./tmp/${APP_PATH}" -target CurrentUserHomeDirectory
    fi
  fi

  rm -rf ./tmp
}

doFinish(){
  waitForKey "press any key to reboot"
  osascript -e 'tell application "System Events" to restart'
}
doDevApps(){
  title "Developer applications"

  # Visual Studio Code
  APP_URL="https://code.visualstudio.com/sha/download?build=stable&os=darwin"
  if [ "${CHIP}" == "arm" ]; then
    APP_URL="https://code.visualstudio.com/sha/download?build=stable&os=darwin-arm64"
  fi
  installApp "Visual Studio Code" $APP_URL

  # TablePlus
  APP_URL="https://www.tableplus.io/release/osx/tableplus_latest"
  installApp "TablePlus" $APP_URL

  # Camunda Modeler
  APP_URL="https://downloads.camunda.cloud/release/camunda-modeler/4.11.1/camunda-modeler-4.11.1-mac.dmg"
  installApp "Camunda Modeler" $APP_URL

  # iTerm
  APP_URL="https://iterm2.com/downloads/stable/latest"
  installApp "iTerm" $APP_URL
  curl -SsL "https://iterm2.com/shell_integration/zsh" > ~/.iterm2_shell_integration.zsh
  chmod +x ~/.iterm2_shell_integration.zsh
  mkdir -p ~/Library/Application\ Support/iTerm2/DynamicProfiles
  cp ./dotfiles/.iterm-local-profile.json ~/Library/Application\ Support/iTerm2/DynamicProfiles/local.json

  # Postman
  APP_URL="https://dl.pstmn.io/download/latest/osx_64"
  if [ "${CHIP}" == "arm" ]; then
    APP_URL="https://dl.pstmn.io/download/latest/osx_arm64"
  fi
  installApp "Postman" $APP_URL

  # Sublime Text
  APP_URL="https://download.sublimetext.com/sublime_text_build_4126_mac.zip"
  installApp "Sublime Text" $APP_URL
  mkdir -p ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
  cp ./dotfiles/Sublime\ Text/*.* ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User

  # NVM & Node.js
  printAction "Install nvm"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  printAction "Install node"
  nvm install node

  # Jira
  if [ -n "$(mas version 2>/dev/null)" ]
  then
    printAction "Install Jira"
    mas install 1475897096
  fi

  # git name and email
  if [ -n "${GIT_USER_NAME}" ]; then
    git config --global user.name "$GIT_USER_NAME"
  fi
  if [ -n "${GIT_USER_EMAIL}" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
  fi
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
  installBrewDevApps
  doDevApps
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
