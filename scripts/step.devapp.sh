#!/usr/bin/env bash

APP_TARGET_PATH="/Applications"

DEVAPP_PREFS+=("Wget;Install wget (brew);ON")
DEVAPP_PREFS+=("MC;Install mc (brew);ON")
DEVAPP_PREFS+=("Postgres;Install postgres (brew);ON")
DEVAPP_PREFS+=("VSC;Visual Studio Code;ON")
DEVAPP_PREFS+=("TablePlus;TablePlus;ON")
DEVAPP_PREFS+=("ITerm;iTerm;ON")
DEVAPP_PREFS+=("SublimeText;Sublime Text;ON")
DEVAPP_PREFS+=("Node;NVM & Node.js;ON")
DEVAPP_PREFS+=("Redis;Install redis (brew);OFF")
DEVAPP_PREFS+=("Camunda;Modeler;OFF")
DEVAPP_PREFS+=("Postman;Postman;OFF")
DEVAPP_PREFS+=("Jira;Jira;OFF")

daWget(){
  brew install wget
}
daMC(){
  brew install mc
}
daRedis(){
  brew install redis
  brew services start redis
}
daPostgres(){
  printAction "Install postgres"
  brew install postgres
  brew services start postgres
  mkdir -p ~/Library/LaunchAgents
  ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
  launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
}
daVSC(){
  APP_URL="https://code.visualstudio.com/sha/download?build=stable&os=darwin"
  if [ "${CHIP}" == "arm" ]; then
    APP_URL="https://code.visualstudio.com/sha/download?build=stable&os=darwin-arm64"
  fi
  installApp "Visual Studio Code" $APP_URL
}
daTablePlus(){
  APP_URL="https://www.tableplus.io/release/osx/tableplus_latest"
  installApp "TablePlus" $APP_URL
}
daCamunda(){
  APP_URL="https://downloads.camunda.cloud/release/camunda-modeler/4.11.1/camunda-modeler-4.11.1-mac.dmg"
  installApp "Camunda Modeler" $APP_URL
}
daITerm(){
  APP_URL="https://iterm2.com/downloads/stable/latest"
  installApp "iTerm" $APP_URL
  curl -SsL "https://iterm2.com/shell_integration/zsh" > ~/.iterm2_shell_integration.zsh
  chmod +x ~/.iterm2_shell_integration.zsh
  mkdir -p ~/Library/Application\ Support/iTerm2/DynamicProfiles
  cp ./dotfiles/.iterm-local-profile.json ~/Library/Application\ Support/iTerm2/DynamicProfiles/local.json
}
daPostman(){
  APP_URL="https://dl.pstmn.io/download/latest/osx_64"
  if [ "${CHIP}" == "arm" ]; then
    APP_URL="https://dl.pstmn.io/download/latest/osx_arm64"
  fi
  installApp "Postman" $APP_URL
}
daSublimeText(){
  APP_URL="https://download.sublimetext.com/sublime_text_build_4126_mac.zip"
  installApp "Sublime Text" $APP_URL
  mkdir -p ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
  cp ./dotfiles/Sublime\ Text/*.* ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
}
daNode(){
  printAction "Install nvm"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  printAction "Install node"
  nvm install node
}
daJira(){
  if [ -n "$(mas version 2>/dev/null)" ]
  then
    printAction "Install Jira"
    mas install 1475897096
  fi
}

askDevApps(){
  if [ $SHOW_DIALOGS -ne 1 ]; then
    RESULT=()
    for PREF in "${DEVAPP_PREFS[@]}"
    do
      IFS=";" read -r -a P <<< "${PREF}"
      RESULT+=("\"${P[0]}\"")
    done
    echo "${RESULT[@]}"
  else
    TITLES=("Ohmymac! Developer applications and tools" "Select what to setup")
    PARAMS=()
    for PREF in "${DEVAPP_PREFS[@]}"
    do
      IFS=";" read -r -a P <<< "${PREF}"
      PARAMS+=("${P[0]}" "${P[1]}" "${P[2]}")
    done

    showCheckboxes "${TITLES[@]}" "${PARAMS[@]}"
  fi
}

installDevApps(){
  TODO=$(askDevApps)

  title "Developer applications and tools"

  for PREF in "${DEVAPP_PREFS[@]}"
  do
    IFS=";" read -r -a P <<< "${PREF}"
    local CODE=${P[0]}
    local TITLE=${P[1]}

    if [[ " ${TODO[*]} " =~ " \"${CODE}\" " ]]; then
      printAction "$TITLE"
      eval "da$CODE"
    fi
  done

  # git name and email
  if [ -n "${GIT_USER_NAME}" ]; then
    git config --global user.name "$GIT_USER_NAME"
  fi
  if [ -n "${GIT_USER_EMAIL}" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
  fi
}
