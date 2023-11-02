#!/usr/bin/env bash

SHORTCUTS_INITED=0

# MacOS
MAC_PREFS+=("RequirePasswordImmediately;MacOS: Require password immediately after sleep or screen saver begins;ON")

# Trackpad
MAC_PREFS+=("TapToClick;Trackpad: Tap to click: Tap with one finger;ON")
MAC_PREFS+=("ClickLight;Trackpad: Click: Light;ON")
MAC_PREFS+=("TrackingSpeedFast;Trackpad: Tracking speed: Fast;ON")
MAC_PREFS+=("DragAndSelect3Fingers;Trackpad: Drag and select with tree fingers;ON")

# Keyboard
MAC_PREFS+=("PressFN;Keyboard: Press fn key to: Show Emoji and Symbols;ON")
MAC_PREFS+=("AutomaticallySwitchInputSource;Keyboard: Automatically switch to document's input source;ON")
MAC_PREFS+=("DisableCapitalization;Keyboard: Disable automatic capitalization;ON")
MAC_PREFS+=("DisablePeriod;Keyboard: Disable automatic period substitution;ON")
MAC_PREFS+=("DisableAutoCorrect;Keyboard: Disable auto-correct;ON")

# Shortcuts
# more information at docs/macos-shortcuts.md
MAC_PREFS+=("PreviousInputSource;Shortcuts: Select the previous input source (cmd + space);ON")
MAC_PREFS+=("NextSourceInMenu;Shortcuts: Select next source in input menu (cmd + opt + space);ON")
MAC_PREFS+=("ShowSpotlight;Shortcuts: Show Spotlight search (ctrl + space);ON")
MAC_PREFS+=("ShowFinerSearch;Shortcuts: Show Finer search window (ctrl + opt + space) (disable);ON")

# Finder
MAC_PREFS+=("SetHomeFolder;Finder: Set home folder as the default location for new Finder windows;ON")
MAC_PREFS+=("DoNotShowIcons;Finder: Do not show icons for hard drives, servers, and removable media on the desktop;ON")
MAC_PREFS+=("ShowAllExtensions;Finder: Show all filename extensions;ON")
MAC_PREFS+=("ShowStatusBar;Finder: Show status bar;ON")
MAC_PREFS+=("DisableTheWarning;Finder: Disable the warning when changing a file extension;ON")

# Dock
MAC_PREFS+=("DoNotAutohide;Dock: Do not autohide;ON")
MAC_PREFS+=("IconSize;Dock: Set the icon size of Dock items;ON")
MAC_PREFS+=("IconMagnification;Dock: Set the icon magnification;ON")
MAC_PREFS+=("DoNotRearrangeSpaces;Dock: Don't automatically rearrange Spaces based on most recent use;ON")
MAC_PREFS+=("ShowIndicatorLights;Dock: Show indicator lights for open applications in the Dock;ON")
MAC_PREFS+=("DoNotShowRecent;Dock: Don't show recent applications in Dock;ON")
MAC_PREFS+=("DoNotShowDashboard;Dock: Don't show Dashboard as a Space;ON")

initShortcutsSet(){
  if [ $SHORTCUTS_INITED -eq 1 ]; then
    return
  fi
  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Delete :AppleSymbolicHotKeys:60" \
    -c "Delete :AppleSymbolicHotKeys:61" \
    -c "Delete :AppleSymbolicHotKeys:64" \
    -c "Delete :AppleSymbolicHotKeys:65" \
    2>/dev/null
  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  SHORTCUTS_INITED=1
}

mpRequirePasswordImmediately(){
  osascript -e 'tell application "System Events" to set require password to wake of security preferences to true'
}
mpTapToClick(){
  defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -int 1
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
}
mpClickLight(){
  defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
  defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 1
}
mpTrackingSpeedFast(){
  defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.5
  defaults write -g com.apple.trackpad.scaling -float 2.5
}
mpDragAndSelect3Fingers(){
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -int 1
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -int 1
}
mpPressFN(){
  # 0 - do nothing
  # 1 - change input source
  # 2 - show emojii & symbols
  # 3 - start dictation
  defaults write com.apple.HIToolbox AppleFnUsageType -int 2
}
mpAutomaticallySwitchInputSource(){
  defaults write com.apple.HIToolbox AppleGlobalTextInputProperties -dict TextInputGlobalPropertyPerContextInput 1
}
mpDisableCapitalization(){
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
}
mpDisablePeriod(){
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
}
mpDisableAutoCorrect(){
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
}
mpPreviousInputSource(){
  initShortcutsSet
  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Add :AppleSymbolicHotKeys:60:enabled bool true" \
    -c "Add :AppleSymbolicHotKeys:60:value:parameters array" \
    -c "Add :AppleSymbolicHotKeys:60:value:parameters: integer 32" \
    -c "Add :AppleSymbolicHotKeys:60:value:parameters: integer 49" \
    -c "Add :AppleSymbolicHotKeys:60:value:parameters: integer 1048576" \
    -c "Add :AppleSymbolicHotKeys:60:value:type string standard"
}
mpNextSourceInMenu(){
  initShortcutsSet
  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Add :AppleSymbolicHotKeys:61:enabled bool true" \
    -c "Add :AppleSymbolicHotKeys:61:value:parameters array" \
    -c "Add :AppleSymbolicHotKeys:61:value:parameters: integer 32" \
    -c "Add :AppleSymbolicHotKeys:61:value:parameters: integer 49" \
    -c "Add :AppleSymbolicHotKeys:61:value:parameters: integer 1572864" \
    -c "Add :AppleSymbolicHotKeys:61:value:type string standard"
}
mpShowSpotlight(){
  initShortcutsSet
  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Add :AppleSymbolicHotKeys:64:enabled bool true" \
    -c "Add :AppleSymbolicHotKeys:64:value:parameters array" \
    -c "Add :AppleSymbolicHotKeys:64:value:parameters: integer 65535" \
    -c "Add :AppleSymbolicHotKeys:64:value:parameters: integer 49" \
    -c "Add :AppleSymbolicHotKeys:64:value:parameters: integer 262144" \
    -c "Add :AppleSymbolicHotKeys:64:value:type string standard"
}
mpShowFinerSearch(){
  initShortcutsSet
  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Add :AppleSymbolicHotKeys:65:enabled bool false" \
    -c "Add :AppleSymbolicHotKeys:65:value:parameters array" \
    -c "Add :AppleSymbolicHotKeys:65:value:parameters: integer 65535" \
    -c "Add :AppleSymbolicHotKeys:65:value:parameters: integer 49" \
    -c "Add :AppleSymbolicHotKeys:65:value:parameters: integer 786432" \
    -c "Add :AppleSymbolicHotKeys:65:value:type string standard"
}
mpSetHomeFolder(){
  defaults write com.apple.finder NewWindowTarget -string "PfHm"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
}
mpDoNotShowIcons(){
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
}
mpShowAllExtensions(){
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
}
mpShowStatusBar(){
  defaults write com.apple.finder ShowStatusBar -bool true
}
mpDisableTheWarning(){
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
}
mpDoNotAutohide(){
  defaults write com.apple.dock autohide -bool false
}
mpIconSize(){
  defaults write com.apple.dock tilesize -int 31
  defaults write com.apple.dock largesize -int 48
}
mpIconMagnification(){
  defaults write com.apple.dock magnification -int 1
}
mpDoNotRearrangeSpaces(){
  defaults write com.apple.dock mru-spaces -int 0
}
mpShowIndicatorLights(){
  defaults write com.apple.dock show-process-indicators -bool true
}
mpDoNotShowRecent(){
  defaults write com.apple.dock show-recents -bool false
}
mpDoNotShowDashboard(){
  defaults write com.apple.dock dashboard-in-overlay -bool true
}

askMacPrefs(){
  if [ $SHOW_DIALOGS -ne 1 ]; then
    RESULT=()
    for PREF in "${MAC_PREFS[@]}"
    do
      IFS=";" read -r -a P <<< "${PREF}"
      RESULT+=("\"${P[0]}\"")
    done
    echo "${RESULT[@]}"
  else
    TITLES=("Ohmymac! MacOS preferences" "Select what to adjust")
    PARAMS=()
    for PREF in "${MAC_PREFS[@]}"
    do
      IFS=";" read -r -a P <<< "${PREF}"
      PARAMS+=("${P[0]}" "${P[1]}" "${P[2]}")
    done

    showCheckboxes "${TITLES[@]}" "${PARAMS[@]}"
  fi
}

doMacPreferences(){
  TODO=$(askMacPrefs)

  title "Macos preferences"

  for PREF in "${MAC_PREFS[@]}"
  do
    IFS=";" read -r -a P <<< "${PREF}"
    local CODE=${P[0]}
    local TITLE=${P[1]}

    if [[ " ${TODO[*]} " =~ " \"${CODE}\" " ]]; then
      printAction "$TITLE"
      eval "mp$CODE"
    fi
  done

  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
}
