#!/bin/bash

PYTHON_FUNCTION=$CB_STATE_DIR/tasks/lab-utils.py

# This function relies on Cloud Shell functions
# If running locally, make sure to set your java version to 11 and
# comment out any references inside save_source.sh and source.sh
function csruntimectl() {
  source /usr/local/bin/manage-runtime "$@"
}

# Retrieve list
listing=$(csruntimectl java list)

# Set the version
version=$(python "$PYTHON_FUNCTION" filter -s $listing)
if [ $? -eq 0 ]; then
    csruntimectl java set $version
else
    echo "Error: Could not switch to a specific java version. Please run csruntimectl manually. For further help, run csruntimectl help."
fi