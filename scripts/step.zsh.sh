#!/usr/bin/env bash

doZshInit(){
  title "zsh"

  # init .zshenv
  printAction "Create .zshenv"
  echo "export LC_ALL=en_US.UTF-8" > ~/.zshenv
  echo "export LANG=en_US.UTF-8" >> ~/.zshenv
  echo "export PATH=\"/opt/homebrew/bin:/usr/local/bin:$PATH\"" >> ~/.zshenv
  if [ $DO_DEV_APPS -eq 1 ]; then
    echo "export EDITOR=mcedit" >> ~/.zshenv
    echo "export NVM_DIR=\"$HOME/.nvm\"" >> ~/.zshenv
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
