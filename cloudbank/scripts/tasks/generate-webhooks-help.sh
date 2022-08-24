#!/bin/bash

# location of terraform
TF_LOCATION=$CB_STATE_DIR/terraform

# Generate Webhooks
IP_ADDRESS="$(terraform -chdir="${TF_LOCATION}" output -json | jq -r .jenkins_public_ip.value)"


CREATE_BRANCH_TOKEN="$(state_get .lab.tokens.create_branch_webhook.secret)"
CREATE_WEBHOOK_ADDRESS="${IP_ADDRESS}/generic-webhook-trigger/invoke?token=${CREATE_BRANCH_TOKEN}"
state_set '.lab.webhooks.create_branch_webhook.payload_url |= $VAL' $CREATE_WEBHOOK_ADDRESS
state_set '.lab.webhooks.create_branch_webhook.content_type |= $VAL' "application/json"
state_set '.lab.webhooks.create_branch_webhook.event |= $VAL' "Branch_or_tag_creation_only"


DELETE_BRANCH_TOKEN="$(state_get .lab.tokens.delete_branch_webhook.secret)"
DELETE_WEBHOOK_ADDRESS="${IP_ADDRESS}/generic-webhook-trigger/invoke?token=${DELETE_BRANCH_TOKEN}"
state_set '.lab.webhooks.delete_branch_webhook.payload_url |= $VAL' $DELETE_WEBHOOK_ADDRESS
state_set '.lab.webhooks.delete_branch_webhook.content_type |= $VAL' "application/json"
state_set '.lab.webhooks.delete_branch_webhook.event |= $VAL' "Branch_or_tag_deletion_only"


PUSH_BRANCH_TOKEN="$(state_get .lab.tokens.push_branch_webhook.secret)"
PUSH_WEBHOOK_ADDRESS="${IP_ADDRESS}/multibranch-webhook-trigger/invoke?token=${PUSH_BRANCH_TOKEN}"
state_set '.lab.webhooks.push_branch_webhook.payload_url |= $VAL' $PUSH_WEBHOOK_ADDRESS
state_set '.lab.webhooks.push_branch_webhook.content_type |= $VAL' "application/json"
state_set '.lab.webhooks.push_branch_webhook.event |= $VAL' "Just_the_push_event"

state_get '.lab.webhooks'