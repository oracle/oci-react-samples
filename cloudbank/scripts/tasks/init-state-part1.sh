#!/bin/bash
# This script is called by setup.sh and initializes the state-file's state values
# This script will require the user to enter the following:
# - Region
# - Compartment OCID
# - Tenancy OCID
# - Jenkins Password

state_set '.state.init_state_a.STARTED |= $VAL' "$( date '+%F_%H:%M:%S' )"

echo "================================================="
echo 'The lab requires the following information to provision resources on OCI...'
echo " - Region"
echo " - Tenancy OCID"
echo " - Compartment OCID"
echo " - Jenkins Password"
echo "================================================="

while : ; do
    read -p "Enter the region identifier for your region (e.g. us-phoenix-1): " INP
    state_set '.lab.region.identifier |= $VAL' $INP

    # requires tenancy OCID
    read -p "Enter the tenancy OCID to authenticate provisioning with: " tOCID
    state_set '.lab.ocid.tenancy |= $VAL' $tOCID

    # requires compartment OCID
    read -p "Enter the compartment OCID to provision resources in: " OCID
    state_set '.lab.ocid.compartment |= $VAL' $OCID

    # requires Jenkins password
    read -s -r -p "Enter the Jenkins credentials to use: " JPWD
    state_set '.lab.pwd.jenkins |= $VAL' $JPWD
    echo "SET"

    (cd $CB_STATE_DIR/tasks ; ./utils-confirm.sh) || break
done

state_set '.state.init_state_a.DONE |= $VAL' "$( date '+%F_%H:%M:%S' )"
