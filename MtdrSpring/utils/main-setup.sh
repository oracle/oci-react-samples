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
    state_set MTDR_DB_NAME "MTDRDB$(state_get RESERVATION_ID)"
    #state_set_done OKE_LIMIT_CHECK
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
while ! state_done USER_OCID; do
  if test -z "$TEST_USER_OCID"; then
    read -p "Please enter your OCI user's OCID: " USER_OCID
  else #this gets used in the terraform file
    USER_OCID=$TEST_USER_OCID
  fi
  # Validate
  if test ""`oci iam user get --user-id "$USER_OCID" --query 'data."lifecycle-state"' --raw-output 2>$MTDRWORKSHOP_LOG/user_ocid_err` == 'ACTIVE'; then
    state_set USER_OCID "$USER_OCID"
  else
    echo "That user OCID could not be validated"
    cat $MTDRWORKSHOP_LOG/user_ocid_err
  fi
done

while ! state_done USER_NAME; do
  USER_NAME=`oci iam user get --user-id "$(state_get USER_OCID)" --query "data.name" --raw-output`
  state_set USER_NAME "$USER_NAME"
done

# Generate Unique Key
while ! state_done MTDR_KEY; do
  state_set MTDR_KEY $(python "$MTDRWORKSHOP_LOCATION/utils/python-scripts/generate-unique-key.py")
done


#Get Run Name from directory name
while ! state_done RUN_NAME; do
  cd $MTDRWORKSHOP_LOCATION
  cd ../..
  # Validate that a folder was creared
  if test "$PWD" == ~; then
    echo "ERROR: The workshop is not installed in a separate folder."
    exit
  fi
  DN=`basename "$PWD"`
  # Validate run name.  Must be between 1 and 13 characters, only letters or numbers, starting with letter
  if [[ "$DN" =~ ^[a-zA-Z][a-zA-Z0-9]{0,12}$ ]]; then
    state_set RUN_NAME `echo "$DN" | awk '{print tolower($0)}'`
    state_set MTDR_DB_NAME "$(state_get RUN_NAME)$(state_get MTDR_KEY)"
  else
    echo "Error: Invalid directory name $RN.  The directory name must be between 1 and 13 characters,"
    echo "containing only letters or numbers, starting with a letter.  Please restart the workshop with a valid directory name."
    exit
  fi
  cd $MTDRWORKSHOP_LOCATION
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


#create the compartment
##newest code added later
while ! state_done COMPARTMENT_OCID; do
  if test $(state_get RUN_TYPE) -ne 3; then
    read -p "if you have your own compartment, enter it here: (if not, hit enter) " COMPARTMENT_OCID
    ##newest condition added
    if test "$COMPARTMENT_OCID" != "" && test `oci iam compartment get --compartment-id "$COMPARTMENT_OCID" --query 'data."lifecycle-state"' --raw-output 2>/dev/null` == 'ACTIVE'; then
      state_set COMPARTMENT_OCID "$COMPARTMENT_OCID"
    else
      echo "Resources will be created in a new compartment named $(state_get RUN_NAME)"
      COMPARTMENT_OCID=`oci iam compartment create --compartment-id "$(state_get TENANCY_OCID)" --name "$(state_get RUN_NAME)" --description "mtdrworkshop" --query 'data.id' --raw-output`
    fi
  fi
  while ! test `oci iam compartment get --compartment-id "$COMPARTMENT_OCID" --query 'data."lifecycle-state"' --raw-output 2>/dev/null`"" == 'ACTIVE'; do
    echo "Waiting for the compartment to become ACTIVE"
    sleep 60
  done
  state_set COMPARTMENT_OCID "$COMPARTMENT_OCID"
done

## Run the java-builds.sh in the background
if ! state_get JAVA_BUILDS; then
  if ps -ef | grep "$MTDRWORKSHOP_LOCATION/utils/java-builds.sh" | grep -v grep; then
    echo "$MTDRWORKSHOP_LOCATION/utils/java-builds.sh is already running"
  else
    echo "Executing java-builds.sh in the background"
    nohup $MTDRWORKSHOP_LOCATION/utils/java-builds.sh &>> $MTDRWORKSHOP_LOG/java-builds.log &
  fi
fi


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
      sleep 60
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
      sleep 5
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
      state_set DOCKER_REGISTRY "$(state_get REGION).ocir.io/$(state_get NAMESPACE)/$(state_get RUN_NAME)/$(state_get MTDR_KEY)"
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
fi

# run db-setup.sh in background
if ! state_get DB_SETUP; then
  if ps -ef | grep "$MTDRWORKSHOP_LOCATION/utils/db-setup.sh" | grep -v grep; then
    echo "$MTDRWORKSHOP_LOCATION/utils/db-setup.sh is already running"
  else
    echo "Executing db-setup.sh in the background"
    nohup $MTDRWORKSHOP_LOCATION/utils/db-setup.sh &>>$MTDRWORKSHOP_LOG/db-setup.log &
  fi
fi

# Collect DB password
if ! state_done DB_PASSWORD; then
  echo
  echo 'Database passwords must be 12 to 30 characters and contain at least one uppercase letter,'
  echo 'one lowercase letter, and one number. The password cannot contain the double quote (")'
  echo 'character or the word "admin".'
  echo

  while true; do
    if test -z "$TEST_DB_PASSWORD"; then
      read -s -r -p "Enter the password to be used for the MTDR database: " PW
    else
      PW="$TEST_DB_PASSWORD"
    fi
    if [[ ${#PW} -ge 12 && ${#PW} -le 30 && "$PW" =~ [A-Z] && "$PW" =~ [a-z] && "$PW" =~ [0-9] && "$PW" != *admin* && "$PW" != *'"'* ]]; then
      echo
      break
    else
      echo "Invalid Password, please retry"
    fi
  done
  BASE64_DB_PASSWORD=`echo -n "$PW" | base64`
fi

# create UI username
if ! state_done UI_USERNAME; then
  echo
  echo 'Create a UI Username'
  echo
  read -s -r -p "Enter the username to be used for accessing the UI: " USERNAME
  state_set UI_USERNAME "$USERNAME"
  export UI_USERNAME="$(state_get UI_USERNAME)"
  state_set_done UI_USERNAME
fi

# Collect UI password and create secret
if ! state_done UI_PASSWORD; then
  echo
  echo 'UI passwords must be 8 to 30 characters'
  echo

  while true; do
    if test -z "$TEST_UI_PASSWORD"; then
      read -s -r -p "Enter the password to be used for accessing the UI: " PW
    else
      PW="$TEST_UI_PASSWORD"
    fi
    if [[ ${#PW} -ge 8 && ${#PW} -le 30 ]]; then
      echo
      break
    else
      echo "Invalid Password, please retry"
    fi
  done
  BASE64_UI_PASSWORD=`echo -n "$PW" | base64`
fi

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


# Get MTDR_DB OCID
while ! state_done MTDR_DB_OCID; do
  MTDR_DB_OCID=`oci db autonomous-database list --compartment-id "$(cat state/COMPARTMENT_OCID)" --query 'join('"' '"',data[?"display-name"=='"'MTDRDB'"'].id)' --raw-output`
  if [[ "$MTDR_DB_OCID" =~ ocid1.autonomousdatabase* ]]; then
    state_set MTDR_DB_OCID "$MTDR_DB_OCID"
  else
    echo "ERROR: Incorrect Order DB OCID: $MTDR_DB_OCID"
    exit
  fi
done


# Wait for kubectl Setup
if ! state_done OKE_NAMESPACE; then
  echo "`date`: Waiting for kubectl configuration and mtdrworkshop namespace"
  while ! state_done OKE_NAMESPACE; do
    LOGLINE=`tail -1 $MTDRWORKSHOP_LOG/state.log`
    echo -ne r"\033[2K\r${LOGLINE:0:120}"
    sleep 2
  done
  echo
fi

# Collect DB password and create secret
while ! state_done DB_PASSWORD; do
  echo "collecting DB password and creating secret"
  while true; do
    if kubectl create -n mtdrworkshop -f -; then
      state_set_done DB_PASSWORD
      break
    else
      echo 'Error: Creating DB Password Secret Failed.  Retrying...'
      sleep 10
    fi <<!
{
   "apiVersion": "v1",
   "kind": "Secret",
   "metadata": {
      "name": "dbuser"
   },
   "data": {
      "dbpassword": "${BASE64_DB_PASSWORD}"
   }
}
!
  done
done


# Set admin password in order database
while ! state_done MTDR_DB_PASSWORD_SET; do
  echo "setting admin password in mtdr_db"
  # get password from vault secret
  DB_PASSWORD=`kubectl get secret dbuser -n mtdrworkshop --template={{.data.dbpassword}} | base64 --decode`
  umask 177
  echo '{"adminPassword": "'"$DB_PASSWORD"'"}' > temp_params
  umask 22
  oci db autonomous-database update --autonomous-database-id "$(state_get MTDR_DB_OCID)" --from-json "file://temp_params" >/dev/null
  rm temp_params
  state_set_done MTDR_DB_PASSWORD_SET
done



# Wait for OKE Setup
while ! state_done OKE_SETUP; do
  echo "`date`: Waiting for OKE_SETUP"
  sleep 2
done

# Create UI password secret
while ! state_done UI_PASSWORD; do
  while true; do
    if kubectl create -n mtdrworkshop -f -; then
      state_set_done UI_PASSWORD
      break
    else
      echo 'Error: Creating UI Password Secret Failed.  Retrying...'
      sleep 10
    fi <<!
{
   "apiVersion": "v1",
   "kind": "Secret",
   "metadata": {
      "name": "frontendadmin"
   },
   "data": {
      "password": "${BASE64_UI_PASSWORD}"
   }
}
!
  done
done


ps -ef | grep "$MTDRWORKSHOP_LOCATION/utils" | grep -v grep

bgs="JAVA_BUILDS OKE_SETUP DB_SETUP PROVISIONING"
while ! state_done SETUP_VERIFIED; do
  NOT_DONE=0
  bg_not_done=
  for bg in $bgs; do
    if state_done $bg; then
      echo "$bg has completed"
    else
      # echo "$bg is running"
      NOT_DONE=$((NOT_DONE+1))
      bg_not_done="$bg_not_done $bg"
    fi
  done
  if test "$NOT_DONE" -gt 0; then
    # echo "Log files are located in $MTDRWORKSHOP_LOG"
    bgs=$bg_not_done
    echo -ne r"\033[2K\r$bgs still running "
    sleep 10
  else
    state_set_done SETUP_VERIFIED
  fi
done

export TEST_VAR='asdf'