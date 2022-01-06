#!/bin/bash
# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Fail on error
set -e

#Check if home is set
if test -z "$MTDRWORKSHOP_LOCATION"; then
  echo "ERROR: this script requires MTDRWORKSHOP_LOCATION to be set"
  exit
fi

#Exit if we are already done
if state_done SETUP_VERIFIED; then
  echo "SETUP_VERIFIED completed"
  exit
fi


#Identify Run Type
#need to edit this
while ! state_done RUN_TYPE; do
  if [[ "$HOME" =~ /home/ll[0-9]{1,5}_us ]]; then
    echo "We are in green button"
    # Green Button (hosted by Live Labs)
    state_set RUN_TYPE "3"
    state_set RESERVATION_ID `grep -oP '(?<=/home/ll).*?(?=_us)' <<<"$HOME"`
    state_set USER_OCID 'NA' #"$OCI_CS_USER_OCID"
    state_set USER_NAME "LL$(state_get RESERVATION_ID)-USER"
    state_set_done PROVISIONING
    state_set_done K8S_PROVISIONING
    state_set RUN_NAME "mtdrworkshop$(state_get RESERVATION_ID)"
    #state_set ORDER_DB_NAME "ORDER$(state_get RESERVATION_ID)" #don't need this
    #state_set INVENTORY_DB_NAME "INVENTORY$(state_get RESERVATION_ID)" #don't need this
    #state_set_done OKE_LIMIT_CHECK # don't need this
    #state_set_done ATP_LIMIT_CHECK
  else
    state_set RUN_TYPE "1"
    # BYO K8s
    if test ${BYO_K8S:-UNSET} != 'UNSET'; then
      state_set_done BYO_K8S
      state_set_done K8S_PROVISIONING
      state_set OKE_OCID 'NA'
      state_set_done KUBECTL
      state_set_done OKE_LIMIT_CHECK
    fi
  fi
done


# Get the User OCID
#if this is a green button then it won't go into this while loop
while ! state_done USER_OCID; do
  if test -z "$TEST_USER_OCID"; then
    read -p "Please enter your OCI user's OCID: " USER_OCID
  else #this gets used in the terraform file
    USER_OCID=$TEST_USER_OCID
  fi
  # Validate
  if test ""`oci iam user get --user-id "$OCI_CS_USER_OCID" --query 'data."lifecycle-state"' --raw-output 2>$MTDRWORKSHOP_LOG/user_ocid_err` == 'ACTIVE'; then
    state_set USER_OCID "$OCI_CS_USER_OCID"
  else
    echo "That user OCID could not be validated"
    cat $MTDRWORKSHOP_LOG/user_ocid_err
  fi
done

#this will only run if not green button
while ! state_done USER_NAME; do
  USER_NAME=`oci iam user get --user-id "$(state_get USER_OCID)" --query "data.name" --raw-output`
  state_set USER_NAME "$USER_NAME"
done

# Get the tenancy OCID
while ! state_done TENANCY_OCID; do
  state_set TENANCY_OCID "$OCI_TENANCY" # Set in cloud shell env, gets used in terraform script
done

# Double check and then set the region
while ! state_done REGION; do
  if test $(state_get RUN_TYPE) -eq 1; then
    HOME_REGION=`oci iam region-subscription list --query 'data[?"is-home-region"]."region-name" | join('\'' '\'', @)' --raw-output`
    state_set HOME_REGION "$HOME_REGION"
  fi
  state_set REGION "$OCI_REGION" # Set in cloud shell env
done


##for testing purposes we won't create the compartment, we'll just ask for the compartment OCID


##uncomment this later for green button
#create the compartment
# while ! state_done COMPARTMENT_OCID; do
#   if test $(state_get RUN_TYPE) -ne 3; then
#     echo "Resources will be created in a new compartment named $(state_get RUN_NAME)"
#     export OCI_CLI_PROFILE=$(state_get HOME_REGION)
#     COMPARTMENT_OCID=`oci iam compartment create --compartment-id "$(state_get TENANCY_OCID)" --name "$(state_get RUN_NAME)" --description "GrabDish Workshop" --query 'data.id' --raw-output`
#     export OCI_CLI_PROFILE=$(state_get REGION)
#   else
#     read -p "Please enter your OCI compartment's OCID: " COMPARTMENT_OCID
#   fi
#   while ! test `oci iam compartment get --compartment-id "$COMPARTMENT_OCID" --query 'data."lifecycle-state"' --raw-output 2>/dev/null`"" == 'ACTIVE'; do
#     echo "Waiting for the compartment to become ACTIVE"
#     sleep 2
#   done
#   state_set COMPARTMENT_OCID "$COMPARTMENT_OCID"
# done
while ! state_done COMPARTMENT_OCID; do
  read -p "Please enter your OCI compartment's OCID" COMPARTMENT_OCID
  echo "Compartment OCID: $COMPARTMENT_OCID"
  state_set COMPARTMENT_OCID "$COMPARTMENT_OCID"
done

## Run the terraform.sh in the background
if ! state_get PROVISIONING; then
  if ps -ef | grep "$MTDRWORKSHOP_LOCATION/utils/terraform.sh" | grep -v grep; then
    echo "$MTDRWORKSHOP_LOCATION/utils/terraform.sh is already running"
  else
    echo "Executing terraform.sh in the background"
    nohup $MTDRWORKSHOP_LOCATION/utils/terraform.sh &>> $MTDRWORKSHOP_LOG/terraform.log &
  fi
fi

# Get Namespace
while ! state_done NAMESPACE; do
  NAMESPACE=`oci os ns get --compartment-id "$(state_get COMPARTMENT_OCID)" --query "data" --raw-output`
  state_set NAMESPACE "$NAMESPACE"
done

# login to docker
while ! state_done DOCKER_REGISTRY; do
  if test $(state_get RUN_TYPE) -ne 3; then
    ##export OCI_CLI_PROFILE=$(state_get HOME_REGION) ## have to get rid of this for non instance_principal based stuff
    if ! TOKEN=`oci iam auth-token create  --user-id "$(state_get USER_OCID)" --description 'mtdr docker login' --query 'data.token' --raw-output 2>$MTDRWORKSHOP_LOG/docker_registry_err`; then
      if grep UserCapacityExceeded $MTDRWORKSHOP_LOG/docker_registry_err >/dev/null; then
        # The key already exists
        echo 'ERROR: Failed to create auth token.  Please delete an old token from the OCI Console (Profile -> User Settings -> Auth Tokens).'
        read -p "Hit return when you are ready to retry?"
        continue
      else
        echo "ERROR: Creating auth token had failed:"
        cat $MTDRWORKSHOP_LOG/docker_registry_err
        exit
      fi
    fi
  else
    read -s -r -p "Please generate an Auth Token and enter the value: " TOKEN
    echo
    echo "Auth Token entry accepted.  Attempting docker login."
  fi

  RETRIES=0
  while test $RETRIES -le 30; do
    if echo "$TOKEN" | docker login -u "$(state_get NAMESPACE)/$(state_get USER_NAME)" --password-stdin "$(state_get REGION).ocir.io" &>/dev/null; then
      echo "Docker login completed"
      state_set DOCKER_REGISTRY "$(state_get REGION).ocir.io/$(state_get NAMESPACE)/$(state_get RUN_NAME)"
      export OCI_CLI_PROFILE=$(state_get REGION)
      break
    else
      # echo "Docker login failed.  Retrying"
      RETRIES=$((RETRIES+1))
      sleep 5
    fi
  done
done
# run oke-setup.sh in background
if ! state_get OKE_SETUP; then
  if ps -ef | grep "$MTDRWORKSHOP_LOCATION/utils/oke-setup.sh" | grep -v grep; then
    echo "$MTDRWORKSHOP_LOCATION/utils/oke-setup.sh is already running"
  else
    echo "Executing oke-setup.sh in the background"
    nohup $MTDRWORKSHOP_LOCATION/utils/oke-setup.sh &>>$MTDRWORKSHOP_LOG/oke-setup.log &
  fi
fi:


# Wait for provisioning
if ! state_done PROVISIONING; then
  echo "`date`: Waiting for terraform provisioning"
  while ! state_done PROVISIONING; do
    LOGLINE=`tail -1 $MTDRWORKSHOP_LOG/terraform.log`
    echo -ne r"\033[2K\r${LOGLINE:0:120}"
    sleep 2
  done
  echo
fi


# Wait for kubectl Setup
if ! state_done OKE_NAMESPACE; then
  echo "`date`: Waiting for kubectl configuration and msdataworkshop namespace"
  while ! state_done OKE_NAMESPACE; do
    LOGLINE=`tail -1 $MTDRWORKSHOP_LOG/state.log`
    echo -ne r"\033[2K\r${LOGLINE:0:120}"
    sleep 2
  done
  echo
fi



# Wait for OKE Setup
while ! state_done OKE_SETUP; do
  echo "`date`: Waiting for OKE_SETUP"
  sleep 2
done

