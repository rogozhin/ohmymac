#!/usr/bin/env bash

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
