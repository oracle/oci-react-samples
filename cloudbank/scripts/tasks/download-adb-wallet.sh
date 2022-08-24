#!/bin/bash

# wallet location
location="$CB_STATE_DIR/generated/wallet.zip"

# retrieve wallet on cloudshell
oci db autonomous-database generate-wallet --autonomous-database-id "$(state_get .lab.ocid.adb)" --file "$location" --password "$(state_get .lab.pwd.db_wallet)" --generate-type='ALL'
