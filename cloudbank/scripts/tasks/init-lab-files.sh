#!/bin/bash

# check if this script needs to run again
COMPLETED_BEFORE=$(state_get .state.init_files.STARTED)
if [ -z "$COMPLETED_BEFORE" ]; then
  echo "SKIPPED."
  exit 0;
fi;


state_set '.state.init_files.STARTED |= $VAL' "$( date '+%F_%H:%M:%S' )"
state_set '.state.init_files.DONE |= $VAL' ""

# Make directories for lab-related files
echo -n 'Beginning Lab setup...'

mkdir -p $CB_STATE_DIR;
mkdir -p $CB_STATE_DIR/terraform;
mkdir -p $CB_STATE_DIR/generated;
mkdir -p $CB_STATE_DIR/logs;
mkdir -p $CB_STATE_DIR/tls;
chmod 700 $CB_STATE_DIR/generated;
chmod 700 $CB_STATE_DIR/logs;
chmod 700 $CB_STATE_DIR/terraform;
chmod 700 $CB_STATE_DIR/tls;
echo 'DONE'


# Copy JSON as new state
echo -n 'Checking state file...'
if [ ! -f $CB_STATE_DIR/state.json ]; then
  echo 'NOT FOUND'
  echo -n 'Generating state file...'
  cp $CB_ROOT_DIR/state.json $CB_STATE_DIR/state.json
  chmod 700 $CB_STATE_DIR/state.json
fi
echo 'DONE'

# Copy Kubernetes scripts
echo -n 'Copying Lab related scripts...'
cp -r $CB_ROOT_DIR/scripts/* $CB_STATE_DIR
echo 'DONE'

# Copy Terraform into state directory
echo -n 'Copying Lab terraform files...'
cp -r $CB_ROOT_DIR/terraform/* $CB_TERRAFORM_DIR
echo 'DONE'

state_set '.state.init_files.DONE |= $VAL' "$( date '+%F_%H:%M:%S' )"