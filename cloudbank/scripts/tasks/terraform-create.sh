#!/bin/bash
CURRENT_TIME=$( date '+%F_%H:%M:%S' )

# set location
location=$CB_TERRAFORM_DIR

# mark start and reset state for done
state_set '.state.provision.STARTED |= $VAL' "$( date '+%F_%H:%M:%S' )"

# create log-file
logfile=$CB_STATE_DIR/logs/$CURRENT_TIME-terraform-apply.log
touch $logfile

# init
terraform -chdir="${location}" init > $logfile

# apply
terraform -chdir="${location}" apply --auto-approve > $logfile

# mark complete
state_set '.state.provision.DONE |= $VAL' "$( date '+%F_%H:%M:%S' )"