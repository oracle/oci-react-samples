#!/bin/bash
# This script is called by setup.sh and initializes the state-file's state values
# This script will require the user to enter the following:
# - Region
# - Compartment OCID
# - Tenancy OCID
# - Jenkins Password

state_set '.state.init_state_a.STARTED |= $VAL' "$( date '+%F_%H:%M:%S' )"

echo "================================================="
echo 'The lab requires the following information to'
echo 'provision resources on OCI...'
echo " - Compartment OCID"
echo " - Jenkins Password"
echo " - Database Password"
echo " - Frontend Login Password"
echo " - Fingerprint"
echo "================================================="

while : ; do
    state_set '.lab.region.identifier |= $VAL' $OCI_REGION

    # requires tenancy OCID
    state_set '.lab.ocid.tenancy |= $VAL' $OCI_TENANCY

    # requires compartment OCID
    read -p "Enter the compartment OCID to provision resources in: " OCID
    state_set '.lab.ocid.compartment |= $VAL' $OCID

    # requires Jenkins password
    read -s -r -p "Enter the Jenkins credentials to use: " JPWD
    state_set '.lab.pwd.jenkins |= $VAL' $JPWD
    echo "SET"


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
    TOK=$(state_get .lab.unique_identifier)
    OCIR="${PROCESSED_RKEY}.ocir.io/${NS}/cloudbank/${TOK}"
    state_set '.lab.docker_registry |= $VAL' $OCIR

    # requires Fingerprint
    read -p "Enter user fingerprint to authenticate provisioning with: " fPRINTVAL
    state_set '.lab.apikey.fingerprint |= $VAL' $fPRINTVAL

    # requires user OCID
    USE_ENV_VARIABLE=0
    echo "Retrieving user..."
    while : ; do
        
        if [ $USE_ENV_VARIABLE -eq 0 ]; then
            UOCID=$OCI_CS_USER_OCID
        else
            read -p "Please enter your User OCID: " UOCID
        fi

        # Check
        OUTPUT=$(oci iam user get --user-id $UOCID 2> /dev/null)
        # User found
        if [ $? -eq 0 ]; then
            echo "User found."
            break
        fi

        echo ""
        echo "Error: User with OCID: $UOCID: NOT FOUND"
        echo "Error: This error is most likely caused by using a federated user and the OCID cannot be retrieved automatically"
        USE_ENV_VARIABLE=1

    done

    uNAME=$(cd $CB_STATE_DIR/tasks ; ./get-user-name.sh $UOCID )
    state_set '.lab.ocid.user |= $VAL' $UOCID
    state_set '.lab.username |= $VAL' $uNAME


    (cd $CB_STATE_DIR/tasks ; ./utils-confirm.sh) || break
done

state_set '.state.init_state_a.DONE |= $VAL' "$( date '+%F_%H:%M:%S' )"
