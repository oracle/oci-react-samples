#!/bin/bash

# This function relies on Cloud Shell functions
# If running locally, make sure to set your java version to 11 and
# comment out any references inside save_source.sh and source.sh
function csruntimectl() {
  source /usr/local/bin/manage-runtime "$@"
}
csruntimectl java set openjdk-11.0.16

