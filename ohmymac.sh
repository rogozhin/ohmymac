#!/usr/bin/env bash

txtred=$(tput setaf 1)    # Red
txtgrn=$(tput setaf 2)    # Green
txtylw=$(tput setaf 3)    # Yellow
txtrst=$(tput sgr0)

DO_MACOS_PREFS=1
DO_DEV_APPS=1
DO_APPS=1

OS="$(uname)"
HAS_SUDO_RIGHTS=1
NEED_SUDO=0

unsetActions(){
  DO_MACOS_PREFS=0
  DO_DEV_APPS=0
  DO_APPS=0
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

  --skip-macos-prefs	Do not set macos preferences
  --skip-dev-apps		Do not install developer applications
  --skip-apps			Do not install non-developer applications
EOF
}

die(){
  echo "${txtred}$*${txtrst}"
  exit 1
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

  		--skip-macos-prefs)
  			DO_MACOS_PREFS=0
  			;;
  		--skip-dev-apps)
  			DO_DEV_APPS=0
  			;;
  		--skip-apps)
  			DO_APPS=0
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

doInitiatory(){
  if [[ "${OS}" != "Darwin" ]]
  then
  	die "Oh! My not Mac!"
  fi

  if [ -z "${BASH_VERSION:-}" ]
  then
  	die "Bash is required to interpret this script"
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
  # TODO print instructions for manual actions
  # - safari
  # - Caffeine.app

  echo ""
  echo "press any key to reboot"
  read -rsn1

  osascript -e 'tell application "System Events" to restart'
}

doMacPreferences(){
  echo "So, fix some macos preferences"


  echo "====="
  echo "Macos"
  echo "====="

  echo "Require password immediately after sleep or screen saver begins"
  osascript -e 'tell application "System Events" to set require password to wake of security preferences to true'


  echo "========"
  echo "Trackpad"
  echo "========"

  echo "Tap to click: Tap with one finger"
  defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -int 1
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  echo "Click: Light"
  defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
  defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 1

  echo "Tracking speed: Fast"
  defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.5
  defaults write -g com.apple.trackpad.scaling -float 2.5

  echo "Drag and select with tree fingers"
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -int 1
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -int 1

  echo "========"
  echo "Keyboard"
  echo "========"

  echo "Press fn key to: Do nothing"
  defaults write com.apple.HIToolbox AppleFnUsageType -int 0

  echo "Automatically switch to document's input source"
  defaults write com.apple.HIToolbox AppleGlobalTextInputProperties -dict TextInputGlobalPropertyPerContextInput 1

  echo "Disable automatic capitalization"
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

  echo "Disable automatic period substitution"
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

  echo "Disable auto-correct"
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

  echo "Shortcuts"
  # If you want to change shortcuts read https://krypted.com/mac-os-x/defaults-symbolichotkeys/ and https://apple.stackexchange.com/questions/91679/is-there-a-way-to-set-an-application-shortcut-in-the-keyboard-preference-pane-vi

  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Delete :AppleSymbolicHotKeys:660" \
    -c "Delete :AppleSymbolicHotKeys:661" \
    -c "Delete :AppleSymbolicHotKeys:664" \
    -c "Delete :AppleSymbolicHotKeys:665" \
    2>/dev/null

  echo "Shortcuts: Select the previous input source (cmd + space)"
  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Add :AppleSymbolicHotKeys:660:enabled bool true" \
    -c "Add :AppleSymbolicHotKeys:660:value:parameters array" \
    -c "Add :AppleSymbolicHotKeys:660:value:parameters: integer 32" \
    -c "Add :AppleSymbolicHotKeys:660:value:parameters: integer 49" \
    -c "Add :AppleSymbolicHotKeys:660:value:parameters: integer 1048576" \
    -c "Add :AppleSymbolicHotKeys:660:type string standard"

  echo "Shortcuts: Select next source in input menu (cmd + opt + space)"
  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Add :AppleSymbolicHotKeys:661:enabled bool true" \
    -c "Add :AppleSymbolicHotKeys:661:value:parameters array" \
    -c "Add :AppleSymbolicHotKeys:661:value:parameters: integer 32" \
    -c "Add :AppleSymbolicHotKeys:661:value:parameters: integer 49" \
    -c "Add :AppleSymbolicHotKeys:661:value:parameters: integer 1572864" \
    -c "Add :AppleSymbolicHotKeys:661:type string standard"

  echo "Shortcuts: Show Spotlight search (ctrl + space)"
  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Add :AppleSymbolicHotKeys:664:enabled bool true" \
    -c "Add :AppleSymbolicHotKeys:664:value:parameters array" \
    -c "Add :AppleSymbolicHotKeys:664:value:parameters: integer 65535" \
    -c "Add :AppleSymbolicHotKeys:664:value:parameters: integer 49" \
    -c "Add :AppleSymbolicHotKeys:664:value:parameters: integer 262144" \
    -c "Add :AppleSymbolicHotKeys:664:type string standard"

  echo "Shortcuts: Show Finer search window (ctrl + opt + space) (disable)"
  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Add :AppleSymbolicHotKeys:665:enabled bool true" \
    -c "Add :AppleSymbolicHotKeys:665:value:parameters array" \
    -c "Add :AppleSymbolicHotKeys:665:value:parameters: integer 65535" \
    -c "Add :AppleSymbolicHotKeys:665:value:parameters: integer 49" \
    -c "Add :AppleSymbolicHotKeys:665:value:parameters: integer 786432" \
    -c "Add :AppleSymbolicHotKeys:665:type string standard"

  echo "======"
  echo "Finder"
  echo "======"

  echo "Set home folder as the default location for new Finder windows"
  defaults write com.apple.finder NewWindowTarget -string "PfHm"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

  echo "Do not show icons for hard drives, servers, and removable media on the desktop"
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

  echo "Show all filename extensions"
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  echo "Show status bar"
  defaults write com.apple.finder ShowStatusBar -bool true

  echo "Disable the warning when changing a file extension"
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false


  echo "===="
  echo "Dock"
  echo "===="

  echo "Do not autohide"
  defaults write com.apple.dock autohide -bool false

  echo "Set the icon size of Dock items"
  defaults write com.apple.dock tilesize -int 31
  defaults write com.apple.dock largesize -int 48

  echo "Set the icon magnification"
  defaults write com.apple.dock magnification -int 1

  echo "Don’t automatically rearrange Spaces based on most recent use"
  defaults write com.apple.dock mru-spaces -int 0

  echo "Show indicator lights for open applications in the Dock"
  defaults write com.apple.dock show-process-indicators -bool true

  echo "Don’t show recent applications in Dock"
  defaults write com.apple.dock show-recents -bool false

  echo "Don’t show Dashboard as a Space"
  defaults write com.apple.dock dashboard-in-overlay -bool true
}

echo "${txtgrn}Hello! Let's setup you new Mac!${txtrst}"

doInitiatory

# set macos prefs
if [ $DO_MACOS_PREFS -eq 1 ]; then
  doMacPreferences
fi

doFinish
