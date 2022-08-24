#!/bin/bash
NS=$(oci os ns get | jq -r .data)
echo $NS