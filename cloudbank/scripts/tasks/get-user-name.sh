#!/bin/bash
USER_OCID="$1"
NAME=$(oci iam user get --user-id $USER_OCID | jq -r .data.name)
echo $NAME