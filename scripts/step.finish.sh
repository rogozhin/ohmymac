#!/usr/bin/env bash

doFinish(){
  waitForKey "press any key to reboot"
  osascript -e 'tell application "System Events" to restart'
}
