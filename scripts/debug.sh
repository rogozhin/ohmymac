#!/usr/bin/env bash

shopt -s expand_aliases

commandEcho(){
  echo "    $1 $2"
}
commandEchoFull(){
  local ARGS=("$@")
  echo "    $1 ${ARGS[@]:1}"
}

alias PlistBuddy="commandEcho PlistBuddy $1"
alias activateSettings="commandEcho activateSettings ''"
alias osascript="commandEcho osascript $1"
alias defaults="commandEchoFull defaults $@"

alias brew="commandEchoFull brew $@"
alias mkdir="commandEchoFull mkdir $@"
alias ln="commandEchoFull ln $@"
alias launchctl="commandEchoFull launchctl $@"
alias curl="commandEchoFull curl $@"
alias nvm="commandEchoFull nvm $@"
alias bash="echo '' ''"
alias mas="commandEchoFull mas $@"
alias chmod="commandEchoFull chmod $@"
alias cp="commandEchoFull cp $@"
alias git="commandEchoFull git $@"
alias wget="commandEchoFull wget $@"
