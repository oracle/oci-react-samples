#!/bin/bash
CURRENT_TIME=$( date '+%F_%H:%M:%S' )

# check if this script needs to run again
COMPLETED_BEFORE=$(state_get .state.provision.DONE)
if [ -z "$COMPLETED_BEFORE" ]; then
  exit 0;
fi;

# Generate Terraform Vars file
echo -n 'Preparing terraform...'
envfile=$CB_TERRAFORM_DIR/terraform.env
. $envfile
echo 'DONE'

# Run terraform
echo -n 'Running terraform provisioning in the background...'
$CB_STATE_DIR/tasks/terraform-create.sh &
echo 'DONE'