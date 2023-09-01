#!/bin/bash
# Sets the following cluster-related objects and settings
# - namespace

# mark start
state_set '.state.clustersetup.STARTED|= $VAL' "$( date '+%F_%H:%M:%S' )"

# Apply Namespace
NS=$(state_get .namespace)
kubectl apply -f $CB_KUBERNETES_TEMPLATES_DIR/namespace.yaml
kubectl config set-context --current --namespace=$NS
kubectl config view --minify | grep namespace:

# Apply service account and secret
kubectl apply -f $CB_KUBERNETES_TEMPLATES_DIR/service-account.yaml
kubectl apply -f $CB_KUBERNETES_TEMPLATES_DIR/service-account-secret.yaml

# Create secret


# Create Load Balancer Certification
$CB_STATE_DIR/gen-lb-cert.sh

# Create secret for frontend-password
kubectl create secret generic cloudbank-password --from-literal=password=$(state_get .lab.pwd.login)

# mark done
state_set '.state.clustersetup.DONE|= $VAL' "$( date '+%F_%H:%M:%S' )"