#!/usr/bin/env bash

APP_PREFS+=("AirServer;AirServer;ON")
APP_PREFS+=("Zoom;Zoom;ON")
APP_PREFS+=("Chrome;Chrome;ON")
APP_PREFS+=("Caffeine;Caffeine;ON")
APP_PREFS+=("Telegram;Telegram;ON")
APP_PREFS+=("Slack;Slack;ON")
APP_PREFS+=("1Blocker;1Blocker;ON")
APP_PREFS+=("Notion;Notion;ON")

apAirServer(){
  APP_URL="https://www.airserver.com/download/mac/latest"
  installApp "AirServer" $APP_URL
}
apZoom(){
  APP_URL="https://zoom.us/client/latest/Zoom.pkg"
  installApp "Zoom" $APP_URL
}
apChrome(){
  APP_URL="https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg"
  installApp "Chrome" $APP_URL
}
apCaffeine(){
  APP_URL="https://github.com/IntelliScape/caffeine/releases/download/1.1.3/Caffeine.dmg"
  installApp "Caffeine" $APP_URL
}
apTelegram(){
    mas install 747648890
}
apSlack(){
    mas install 803453959
}
ap1Blocker(){
    mas install 1365531024
}
apNotion(){
  APP_URL="https://www.notion.so/desktop/mac-universal/download"
  installApp "Notion" $APP_URL
}

installApps(){
  TODO=$(askPrefs "Ohmymac! Applications and tools" "Select what to setup" APP_PREFS)

  title "Applications and tools"

  for PREF in "${APP_PREFS[@]}"
  do
    IFS=";" read -r -a P <<< "${PREF}"
    local CODE=${P[0]}
    local TITLE=${P[1]}

    if [[ " ${TODO[*]} " =~ " \"${TITLE}\" " ]]; then
      printAction "$TITLE"
      eval "ap$CODE"
    fi
  done
}
