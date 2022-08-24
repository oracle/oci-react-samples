#!/bin/bash

if [ -z "$CB_ROOT_DIR" ]; then
  SCRIPT_LOCATION="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
  CB_ROOT_DIR="$SCRIPT_LOCATION/.."
fi;

# Application 1
APP_FE_BUILD_SCRIPT_LOCATION="$CB_ROOT_DIR/frontend-springboot"
APP_FE_BUILD_SCRIPT_FILENAME="deploy.sh"

# Build
state_set '.state.apps.cloudbank_frontend.DEPLOY_STARTED |= $VAL' "$( date '+%F_%H:%M:%S' )"
(cd "$APP_FE_BUILD_SCRIPT_LOCATION" || exit ; sh "$APP_FE_BUILD_SCRIPT_FILENAME")
state_set '.state.apps.cloudbank_frontend.DEPLOY_COMPLETED |= $VAL' "$( date '+%F_%H:%M:%S' )"

# Application 2
APP_BE_BUILD_SCRIPT_LOCATION="$CB_ROOT_DIR/backend-springboot"
APP_BE_BUILD_SCRIPT_FILENAME="deploy.sh"

# Build
state_set '.state.apps.cloudbank_backend.DEPLOY_STARTED |= $VAL' "$( date '+%F_%H:%M:%S' )"
(cd "$APP_BE_BUILD_SCRIPT_LOCATION" || exit ; sh "$APP_BE_BUILD_SCRIPT_FILENAME")
state_set '.state.apps.cloudbank_backend.DEPLOY_COMPLETED |= $VAL' "$( date '+%F_%H:%M:%S' )"