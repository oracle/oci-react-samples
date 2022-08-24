#!/bin/bash


if [ -f ~/.bashrc-cbworkshop-backup ]; then
  # for BASH, create backup
  mv ~/.bashrc-cbworkshop-backup ~/.bashrc
elif [ -f ~/.zshrc-cbworkshop-backup ]; then
  # for ZSH, create backup
  mv ~/.zshrc-cbworkshop-backup ~/.zshrc
else
    echo "Error: The ~/.zshrc or ~/.bashrc backup file not found. Please manually remove the lab-related commands inside ~/.zshrc or ~/.bashrc"
fi