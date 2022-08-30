#!/bin/bash
CURRENT_TIME=$( date '+%F_%H:%M:%S' )

# Mark Start of Script
state_set '.state.dbsetup.STARTED|= $VAL' "$( date '+%F_%H:%M:%S' )"
echo -n "Initializing Autonomous Database (ADB)..."

# Download ADB Wallet
location="$CB_STATE_DIR/generated/wallet.zip"
CONNSERVICE="$(state_get .lab.db.name)_tp"
$CB_STATE_DIR/tasks/download-adb-wallet.sh

# Retrieve Password
password=$(state_get .lab.fixed_demo_user_credential)
if [ -z "$password" ]; then
  echo ''
  echo "Error: Database user credentials were not found and the database cannot be initialized."
  state_set '.state.dbsetup.ERROR|= $VAL' "$( date '+%F_%H:%M:%S' )"
  exit 1;
fi

# Navigate to SQL directory and Run Initialization
touch $CB_STATE_DIR/logs/$CURRENT_TIME-sql-setup.log
(cd $CB_ROOT_DIR/sql || exit ;  ./configure-adb.sh $location $password $CONNSERVICE > $CB_STATE_DIR/logs/$CURRENT_TIME-sql-setup.log)
echo "DONE"

# mark completed
state_set '.state.dbsetup.DONE|= $VAL' "$( date '+%F_%H:%M:%S' )"