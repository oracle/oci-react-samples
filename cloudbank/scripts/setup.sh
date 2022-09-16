#!/bin/bash
CURRENT_TIME=$( date '+%F_%H:%M:%S' )

# Fail on error
set -eu

# Check if any of the necessary env variables exist
if [ -z $CB_STATE_DIR ] | [ -z $CB_KUBERNETES_TEMPLATES_DIR ] | [ -z $CB_ROOT_DIR ]; then
  echo 'Error: Lab variables not set. Please source source.env first';
  exit 1;
fi

# Init Lab Files by copying scripts and state
$CB_ROOT_DIR/scripts/tasks/init-lab-files.sh

# Set source env inside bashrc
$CB_STATE_DIR/tasks/save_source.sh

# Set (3) Tokens for Jenkins
$CB_STATE_DIR/tasks/generate-tokens.sh
echo ''

# Prompt user for input on setup
$CB_STATE_DIR/tasks/init-state-part1.sh

# Run terraform
$CB_STATE_DIR/init-infrastructure.sh
echo ''
