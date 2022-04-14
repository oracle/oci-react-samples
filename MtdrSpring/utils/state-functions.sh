#!/bin/bash
# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Make sure this is run via source or .
if ! (return 0 2>/dev/null); then
  echo "ERROR: Usage: 'source state-functions.sh"
  exit
fi

if test -z "$MTDRWORKSHOP_STATE_HOME"; then
  echo "ERROR: The mtdrworkshopt state home folder was not set"
else
  mkdir -p $MTDRWORKSHOP_STATE_HOME/state
fi

function state_done() {
  test -f $MTDRWORKSHOP_STATE_HOME/state/"$1"
}

# Set the state to done
function state_set_done() {
  touch $MTDRWORKSHOP_STATE_HOME/state/"$1"
  echo "`date`: $1" >>$MTDRWORKSHOP_LOG/state.log
  echo "$1 completed"
}

# Set the state to done and it's value
function state_set() {
  echo "$2" > $MTDRWORKSHOP_STATE_HOME/state/"$1"
  echo "`date`: $1: $2" >>$MTDRWORKSHOP_LOG/state.log
  echo "$1: $2"
}

# Reset the state - not done and no value
function state_reset() {
  rm -f $MTDRWORKSHOP_STATE_HOME/state/"$1"
}

# Get state value
function state_get() {
    if ! state_done "$1"; then
        return 1
    fi
    cat $MTDRWORKSHOP_STATE_HOME/state/"$1"
}

# Export the functions so that they are available to subshells
export -f state_done
export -f state_set_done
export -f state_set
export -f state_reset
export -f state_get
