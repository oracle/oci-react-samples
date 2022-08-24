#!/bin/bash
envfile=$CB_TERRAFORM_DIR/terraform.env

echo -n 'Preparing terraform...'
. $envfile
echo 'DONE'