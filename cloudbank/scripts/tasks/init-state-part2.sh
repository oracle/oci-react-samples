#!/bin/bash
# This script is called by setup.sh and initializes the state-file's state values
# This script will require the user to enter the following:
# - Database Password
# - Frontend Login Password
# - OCI Registry
# - User OCID
# - Fingerprint

# requires Database Password

state_set '.state.init_state_b.STARTED |= $VAL' "$( date '+%F_%H:%M:%S' )"

echo "================================================="
echo 'The lab requires the following information to provision resources on OCI...'
echo " - Database Password"
echo " - Frontend Login Password"
echo " - Region Key"
echo " - User OCID"
echo " - Fingerprint"
echo "================================================="


while : ; do

    read -s -r -p "Enter the Database password to use: " DBPWD
    state_set '.lab.pwd.db |= $VAL' $DBPWD
    state_set '.lab.pwd.db_wallet |= $VAL' $DBPWD
    echo "SET"

    # requires Frontend login Password"
    read -s -r -p "Enter the Frontend Login password to use: " FEPWD
    state_set '.lab.pwd.login |= $VAL' $FEPWD
    echo "SET"

    # requires Reqion Key
    #  -p "Enter the region-key to use (e.g. phx, iad, etc.): " RKEY
    REGION=$(state_get '.lab.region.identifier')
    RKEY=$(oci iam region list | jq -r --arg REGION "${REGION}" '.data[] | select (.name == $REGION) | .key ')
    PROCESSED_RKEY=$(cd $CB_STATE_DIR/tasks ; ./utils-lower-text.sh $RKEY )
    state_set '.lab.region.key |= $VAL' $PROCESSED_RKEY

    # requires Tenancy Namespace
    NS=$(cd $CB_STATE_DIR/tasks ; ./get-tenancy-namespace.sh )
    state_set '.lab.tenancy.namespace |= $VAL' $NS

    # requires OCIR registry
    TOK=$(state_get .lab.ocir_unique_identifier)
    OCIR="${RKEY}.ocir.io/${NS}/cloudbank/${TOK}"
    state_set '.lab.docker_registry |= $VAL' $OCIR

    # requires user OCID
    read -p "Enter the user OCID to authenticate provisioning with: " uOCID
    state_set '.lab.ocid.user |= $VAL' $uOCID

    # requires username
    uNAME=$(cd $CB_STATE_DIR/tasks ; ./get-user-name.sh $uOCID )
    state_set '.lab.username |= $VAL' $uNAME

    # requires Fingerprint
    read -p "Enter user fingerprint to authenticate provisioning with: " fPRINTVAL
    state_set '.lab.apikey.fingerprint |= $VAL' $fPRINTVAL

    (cd $CB_STATE_DIR/tasks ; ./utils-confirm.sh) || break
done

state_set '.state.init_state_b.DONE |= $VAL' "$( date '+%F_%H:%M:%S' )"
