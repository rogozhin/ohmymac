#!/usr/bin/env bash

txtred=$(tput setaf 1)    # Red
txtgrn=$(tput setaf 2)    # Green
txtylw=$(tput setaf 3)    # Yellow
txtblu=$(tput setaf 4)    # Blue
txtrst=$(tput sgr0)

DO_MACOS_PREFS=1
DO_DEV_APPS=1
DO_APPS=1
DO_MANUAL_LIST=1
DO_ALL=1

OS="$(uname)"
HAS_SUDO_RIGHTS=1
NEED_SUDO=0
CHIP="$(uname -p)"

unsetActions(){
  DO_MACOS_PREFS=0
  DO_DEV_APPS=0
  DO_APPS=0
  DO_MANUAL_LIST=0
  DO_ALL=0
}

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

# shift and
# if [ $# -eq 0 -o "${1:0:1}" = "-" ]; then
# 	die "The ${opt} option requires an argument."
# fi
# for options with value
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

installBrew(){
  title "Brew"

  if [ -z "$(brew --version 2>/dev/null)" ]
  then
    printAction "Install brew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
  fi

  printAction "Install mas"
  brew install mas

  if [ $DO_DEV_APPS -eq 1 ]; then
    printAction "Install wget"
    brew install wget
    printAction "Install mc"
    brew install mc

    printAction "Install postgres"
    brew install postgres
    mkdir -p ~/Library/LaunchAgents
    ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
  fi
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

doInitiatory(){
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

  if [ -z "$(groups | grep admin)" ]
  then
  	HAS_SUDO_RIGHTS=0
  fi

  # Close any open System Preferences panes, to prevent them from overriding settings
  osascript -e 'tell application "System Preferences" to quit'

  if [ $HAS_SUDO_RIGHTS -eq 1 ] && [ $NEED_SUDO -eq 1 ]
  then
  	# Ask password and prevent to ask again
  	sudo -v
  	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
  fi
}
doFinish(){
  waitForKey "press any key to reboot"
  osascript -e 'tell application "System Events" to restart'
}
doMacPreferences(){
  title "Macos preferences"

  subtitle "Macos"
  printAction "Require password immediately after sleep or screen saver begins"
  osascript -e 'tell application "System Events" to set require password to wake of security preferences to true'

  subtitle "Trackpad"

  printAction "Tap to click: Tap with one finger"
  defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -int 1
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  printAction "Click: Light"
  defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
  defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 1

  printAction "Tracking speed: Fast"
  defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.5
  defaults write -g com.apple.trackpad.scaling -float 2.5

  printAction "Drag and select with tree fingers"
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -int 1
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -int 1

  subtitle "Keyboard"

  printAction "Press fn key to: Do nothing"
  defaults write com.apple.HIToolbox AppleFnUsageType -int 0

  printAction "Automatically switch to document's input source"
  defaults write com.apple.HIToolbox AppleGlobalTextInputProperties -dict TextInputGlobalPropertyPerContextInput 1

  printAction "Disable automatic capitalization"
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

  printAction "Disable automatic period substitution"
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

  printAction "Disable auto-correct"
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

  subtitle "Shortcuts"
  # more information at docs/macos-shortcuts.md

  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Delete :AppleSymbolicHotKeys:60" \
    -c "Delete :AppleSymbolicHotKeys:61" \
    -c "Delete :AppleSymbolicHotKeys:64" \
    -c "Delete :AppleSymbolicHotKeys:65" \
    2>/dev/null
  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

  printAction "Select the previous input source (cmd + space)"
  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Add :AppleSymbolicHotKeys:60:enabled bool true" \
    -c "Add :AppleSymbolicHotKeys:60:value:parameters array" \
    -c "Add :AppleSymbolicHotKeys:60:value:parameters: integer 32" \
    -c "Add :AppleSymbolicHotKeys:60:value:parameters: integer 49" \
    -c "Add :AppleSymbolicHotKeys:60:value:parameters: integer 1048576" \
    -c "Add :AppleSymbolicHotKeys:60:value:type string standard"

  printAction "Select next source in input menu (cmd + opt + space)"
  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Add :AppleSymbolicHotKeys:61:enabled bool true" \
    -c "Add :AppleSymbolicHotKeys:61:value:parameters array" \
    -c "Add :AppleSymbolicHotKeys:61:value:parameters: integer 32" \
    -c "Add :AppleSymbolicHotKeys:61:value:parameters: integer 49" \
    -c "Add :AppleSymbolicHotKeys:61:value:parameters: integer 1572864" \
    -c "Add :AppleSymbolicHotKeys:61:value:type string standard"

  printAction "Show Spotlight search (ctrl + space)"
  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Add :AppleSymbolicHotKeys:64:enabled bool true" \
    -c "Add :AppleSymbolicHotKeys:64:value:parameters array" \
    -c "Add :AppleSymbolicHotKeys:64:value:parameters: integer 65535" \
    -c "Add :AppleSymbolicHotKeys:64:value:parameters: integer 49" \
    -c "Add :AppleSymbolicHotKeys:64:value:parameters: integer 262144" \
    -c "Add :AppleSymbolicHotKeys:64:value:type string standard"

  printAction "Show Finer search window (ctrl + opt + space) (disable)"
  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Add :AppleSymbolicHotKeys:65:enabled bool false" \
    -c "Add :AppleSymbolicHotKeys:65:value:parameters array" \
    -c "Add :AppleSymbolicHotKeys:65:value:parameters: integer 65535" \
    -c "Add :AppleSymbolicHotKeys:65:value:parameters: integer 49" \
    -c "Add :AppleSymbolicHotKeys:65:value:parameters: integer 786432" \
    -c "Add :AppleSymbolicHotKeys:65:value:type string standard"

  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

  subtitle "Finder"

  printAction "Set home folder as the default location for new Finder windows"
  defaults write com.apple.finder NewWindowTarget -string "PfHm"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

  printAction "Do not show icons for hard drives, servers, and removable media on the desktop"
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

  printAction "Show all filename extensions"
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  printAction "Show status bar"
  defaults write com.apple.finder ShowStatusBar -bool true

  printAction "Disable the warning when changing a file extension"
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

  subtitle "Dock"

  printAction "Do not autohide"
  defaults write com.apple.dock autohide -bool false

  printAction "Set the icon size of Dock items"
  defaults write com.apple.dock tilesize -int 31
  defaults write com.apple.dock largesize -int 48

  printAction "Set the icon magnification"
  defaults write com.apple.dock magnification -int 1

  printAction "Don't automatically rearrange Spaces based on most recent use"
  defaults write com.apple.dock mru-spaces -int 0

  printAction "Show indicator lights for open applications in the Dock"
  defaults write com.apple.dock show-process-indicators -bool true

  printAction "Don't show recent applications in Dock"
  defaults write com.apple.dock show-recents -bool false

  printAction "Don't show Dashboard as a Space"
  defaults write com.apple.dock dashboard-in-overlay -bool true
}
doZshInit(){
  title "zsh"

  # init .zshenv
  printAction "Create .zshenv"
  echo "export LC_ALL=en_US.UTF-8" > ~/.zshenv
  echo "export LANG=en_US.UTF-8" >> ~/.zshenv
  echo "export PATH=\"/opt/homebrew/bin:/usr/local/bin:$PATH\"" >> ~/.zshenv
  if [ $DO_DEV_APPS -eq 1 ]; then
    echo "export EDITOR=mcedit" >> ~/.zshenv
    echo "export NVM_DIR=\"$HOME/.nvm\""
  fi

  # init .zshrc
  printAction "Create .zshrc"
  cat ./dotfiles/.zsh-core > ~/.zshrc
  if [ $DO_DEV_APPS -eq 1 ]; then
    cat ./dotfiles/.zsh-git >> ~/.zshrc
    cat ./dotfiles/.zsh-iterm >> ~/.zshrc
    cat ./dotfiles/.zsh-nvm >> ~/.zshrc

    cp ./dotfiles/.huskyrc ~/.huskyrc
  fi
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

  # Pritunl
  APP_URL="https://github.com/pritunl/pritunl-client-electron/releases/download/1.2.3019.52/Pritunl.pkg.zip"
  if [ "${CHIP}" == "arm" ]; then
    APP_URL="https://github.com/pritunl/pritunl-client-electron/releases/download/1.2.3019.52/Pritunl.arm64.pkg.zip"
  fi
  installApp "Pritunl" $APP_URL

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
  fi
}

echo "${txtgrn}Hello! Let's setup your new Mac!${txtrst}"

if [ $DO_DEV_APPS -eq 1 ] || [ $DO_APPS -eq 1 ]
then
  waitForKey "Be sure to log into the AppStore then press any key to start"
fi

doInitiatory

if [ $DO_MACOS_PREFS -eq 1 ]; then
  doMacPreferences
  installBrew
fi

if [ $DO_ALL -eq 1 ]; then
  doZshInit
fi

if [ $DO_DEV_APPS -eq 1 ]; then
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
