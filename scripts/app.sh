#!/usr/bin/env bash

installApp(){
  APP_NAME=$1
  APP_URL=$2
  TARGET_PATH=$APP_TARGET_PATH

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
