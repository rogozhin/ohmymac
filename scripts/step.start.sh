#!/usr/bin/env bash

setDoValue(){
  local DO_NAME=$1
  local ARGS=("$@")
  local TODO=("${ARGS[@]:1}")
  local VAL=0

  if [[ " ${TODO[*]} " =~ " \"${DO_NAME}\" " ]]; then
    VAL=1
  fi
  eval "$DO_NAME"=$VAL
}

askWhatToDo(){
  if [ $SHOW_DIALOGS -ne 1 ]; then
    return
  fi

  TITLES=("Ohmymac! settings" "Select what to do")
  PARAMS+=("DO_ZSH_INIT" "Init zsh settings" `isSelectedOption $DO_ZSH_INIT $DO_ALL`)
  PARAMS+=("DO_MACOS_PREFS" "Set macos preferences" `isSelectedOption $DO_MACOS_PREFS $DO_ALL`)
  PARAMS+=("DO_APPS" "Set applications" `isSelectedOption $DO_APPS $DO_ALL`)
  PARAMS+=("DO_DEV_APPS" "Set developer applications" `isSelectedOption $DO_DEV_APPS $DO_ALL`)
  PARAMS+=("DO_MANUAL_LIST" "Show manual actions" `isSelectedOption $DO_MANUAL_LIST $DO_ALL`)

  TODO=$(showCheckboxes "${TITLES[@]}" "${PARAMS[@]}")

  setDoValue DO_ZSH_INIT "${TODO[@]}"
  setDoValue DO_MACOS_PREFS "${TODO[@]}"
  setDoValue DO_APPS "${TODO[@]}"
  setDoValue DO_DEV_APPS "${TODO[@]}"
  setDoValue DO_MANUAL_LIST "${TODO[@]}"
}
