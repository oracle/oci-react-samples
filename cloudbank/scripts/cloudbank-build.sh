#!/bin/bash

# Determine Root DIR
if [ -z "$CB_ROOT_DIR" ]; then
  SCRIPT_LOCATION="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
  CB_ROOT_DIR="$SCRIPT_LOCATION/.."
fi;

# Variables
APP_FE_DIR="frontend-springboot"
APP_BE_DIR="backend-springboot"
BUILD_SCRIPT="build.sh"


# create and copy app directories inside state
echo -n "Copying applications into state directory..."
mkdir -p "$CB_STATE_DIR/apps"
cp -TR "$CB_ROOT_DIR/$APP_FE_DIR/" "$CB_STATE_DIR/apps/$APP_FE_DIR/"
cp -TR "$CB_ROOT_DIR/$APP_BE_DIR/" "$CB_STATE_DIR/apps/$APP_BE_DIR/"
echo "DONE"


# Build App 1
state_set '.state.apps.cloudbank_frontend.BUILD_STARTED |= $VAL' "$( date '+%F_%H:%M:%S' )"
(cd "$CB_STATE_DIR/apps/$APP_FE_DIR" || exit ; sh "$BUILD_SCRIPT")
state_set '.state.apps.cloudbank_frontend.BUILD_COMPLETED |= $VAL' "$( date '+%F_%H:%M:%S' )"

echo ""

# Build App 2
state_set '.state.apps.cloudbank_backend.BUILD_STARTED |= $VAL' "$( date '+%F_%H:%M:%S' )"
(cd "$CB_STATE_DIR/apps/$APP_BE_DIR" || exit ; sh "$BUILD_SCRIPT")
state_set '.state.apps.cloudbank_backend.BUILD_COMPLETED |= $VAL' "$( date '+%F_%H:%M:%S' )"