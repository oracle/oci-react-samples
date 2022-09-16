#!/bin/bash

# location of terraform
TF_LOCATION=$CB_STATE_DIR/terraform
IP_ADDRESS="$(terraform -chdir="${TF_LOCATION}" output -json | jq -r .jenkins_public_ip.value)"

# Generate Webhooks Help
echo -n "Generating Jenkins list of webhook configuration..."
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
echo "DONE"

# Generate Jenkins Credentials Help
echo -n "Generating Jenkins list of credentials..."
CREATE_BRANCH_TOKEN="$(state_get .lab.tokens.create_branch_webhook.secret)"
state_set '.lab.credentials.create_branch_webhook.kind |= $VAL' 'secret_text'
state_set '.lab.credentials.create_branch_webhook.secret |= $VAL' "$CREATE_BRANCH_TOKEN"
state_set '.lab.credentials.create_branch_webhook.id |= $VAL' 'cbworkshop-create-branch-token'


DELETE_BRANCH_TOKEN="$(state_get .lab.tokens.delete_branch_webhook.secret)"
state_set '.lab.credentials.delete_branch_webhook.kind |= $VAL' 'secret_text'
state_set '.lab.credentials.delete_branch_webhook.secret |= $VAL' "$DELETE_BRANCH_TOKEN"
state_set '.lab.credentials.delete_branch_webhook.id |= $VAL' 'cbworkshop-delete-branch-token'


PUSH_BRANCH_TOKEN="$(state_get .lab.tokens.push_branch_webhook.secret)"
state_set '.lab.credentials.push_branch_webhook.kind |= $VAL' 'secret_text'
state_set '.lab.credentials.push_branch_webhook.secret |= $VAL' "$PUSH_BRANCH_TOKEN"
state_set '.lab.credentials.push_branch_webhook.id |= $VAL' 'cbworkshop-push-token'


TENANCY_NAMESPACE="$(state_get .lab.tenancy.namespace)"
state_set '.lab.credentials.tenancy_namespace.kind |= $VAL' 'secret_text'
state_set '.lab.credentials.tenancy_namespace.secret |= $VAL' "$TENANCY_NAMESPACE"
state_set '.lab.credentials.tenancy_namespace.id |= $VAL' 'cbworkshop-tenancy-namespace'


REGION_KEY="$(state_get .lab.region.key)"
state_set '.lab.credentials.region_key.kind |= $VAL' 'secret_text'
state_set '.lab.credentials.region_key.secret |= $VAL' "$REGION_KEY"
state_set '.lab.credentials.region_key.id |= $VAL' 'cbworkshop-region-key'

CLUSTER_NAME="$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')"
state_set '.lab.credentials.cluster_name.kind |= $VAL' 'secret_text'
state_set '.lab.credentials.cluster_name.secret |= $VAL' "$CLUSTER_NAME"
state_set '.lab.credentials.cluster_name.id |= $VAL' 'cbworkshop-cluster-name'


CLUSTER_SERVER_URL="$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')"
state_set '.lab.credentials.cluster_server_url.kind |= $VAL' 'secret_text'
state_set '.lab.credentials.cluster_server_url.secret |= $VAL' "$CLUSTER_SERVER_URL"
state_set '.lab.credentials.cluster_server_url.id |= $VAL' 'cbworkshop-cluster-server-url'


CLUSTER_TOKEN="$(kubectl -n kube-system get secret $(kubectl -n kube-system get secret | grep kube-cicd | awk '{print $1}') -o jsonpath='{.data.token}' | base64 -d)"
state_set '.lab.credentials.cluster_token.kind |= $VAL' 'secret_text'
state_set '.lab.credentials.cluster_token.secret |= $VAL' "$CLUSTER_TOKEN"
state_set '.lab.credentials.cluster_token.id |= $VAL' 'cbworkshop-kubectl-token'

DB_PASSWORD="$(state_get .lab.fixed_demo_user_credential)"
state_set '.lab.credentials.db_password.kind |= $VAL' 'secret_text'
state_set '.lab.credentials.db_password.secret |= $VAL' "$DB_PASSWORD"
state_set '.lab.credentials.db_password.id |= $VAL' 'cbworkshop-default-db-password'

UNIQUEID="$(state_get .lab.unique_identifier)"
state_set '.lab.credentials.lab_unique_id.kind |= $VAL' 'secret_text'
state_set '.lab.credentials.lab_unique_id.secret |= $VAL' "$UNIQUEID"
state_set '.lab.credentials.lab_unique_id.id |= $VAL' 'cbworkshop-unique-id'


YOUR_GITHUB_USERNAME="<your-github-username>"
YOUR_GITHUB_CREDENTIALS="<your-github-credentials>"
state_set '.lab.credentials.github_credentials.kind |= $VAL' 'username_with_password'
state_set '.lab.credentials.github_credentials.username |= $VAL' $YOUR_GITHUB_USERNAME
state_set '.lab.credentials.github_credentials.password |= $VAL' "$YOUR_GITHUB_CREDENTIALS"
state_set '.lab.credentials.github_credentials.id |= $VAL' 'cbworkshop-github-credentials'


YOUR_OCIR_USERNAME="$(state_get .lab.tenancy.namespace)/$(state_get .lab.username)"
YOUR_OCIR_CREDENTIALS="<your-auth-token>"
state_set '.lab.credentials.ocir_credentials.kind |= $VAL' 'username_with_password'
state_set '.lab.credentials.ocir_credentials.username |= $VAL' $YOUR_OCIR_USERNAME
state_set '.lab.credentials.ocir_credentials.password |= $VAL' "$YOUR_OCIR_CREDENTIALS"
state_set '.lab.credentials.ocir_credentials.id |= $VAL' 'cbworkshop_ocir_credentials_id'
echo "DONE"

# Retreiving IP address
echo ""
echo "Retreiving Jenkins IP Address..."
terraform -chdir="$CB_STATE_DIR/terraform" output -json | jq -r .jenkins_public_ip.value