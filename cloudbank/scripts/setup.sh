#!/bin/bash
CURRENT_TIME=$( date '+%F_%H:%M:%S' )

# Check if any of the necessary env variables exist
if [ -z $CB_STATE_DIR ] | [ -z $CB_KUBERNETES_TEMPLATES_DIR ] | [ -z $CB_ROOT_DIR ]; then
  echo 'Error: Lab variables not set. Please source source.env first';
  exit 1;
fi

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


# Set source env inside bashrc
echo -n 'Saving Lab settings...'
$CB_STATE_DIR/tasks/save_source.sh
echo 'DONE'


# Copy Terraform into state directory
echo -n 'Copying Lab terraform files...'
cp -r $CB_ROOT_DIR/terraform/* $CB_TERRAFORM_DIR
echo 'DONE'
echo ''

# Prompt user for input on setup
echo "================================================="
echo 'The lab requires the following information to provision resources on OCI...'
echo " - Region"
echo " - Compartment OCID"
echo " - Tenancy OCID"
echo " - Jenkins Password"
echo "================================================="
$CB_STATE_DIR/tasks/init-state-part1.sh


# Set (3) Tokens for Jenkins
echo -n 'Generate tokens...'
$CB_STATE_DIR/tasks/generate-tokens.sh
echo 'DONE'
echo ''


# Run terraform
echo "Terraforming Resources on OCI..."
$CB_STATE_DIR/init-infrastructure.sh
echo ''


# Continue rest of retrieving values from end-user
echo "================================================="
echo 'The lab requires the following information to provision resources on OCI...'
echo " - Database Password"
echo " - Frontend Login Password"
echo " - Region Key"
echo " - User OCID"
echo " - Fingerprint"
echo "================================================="
$CB_STATE_DIR/tasks/init-state-part2.sh


