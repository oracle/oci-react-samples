#!/bin/bash
# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Fail on error
set -e


# Create SSL Certs
while ! state_done SSL; do
  mkdir -p $MTDRWORKSHOP_LOCATION/tls
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $MTDRWORKSHOP_LOCATION/tls/tls.key -out $MTDRWORKSHOP_LOCATION/tls/tls.crt -subj "/CN=grabdish/O=grabdish"
  state_set_done SSL
done


# Wait for provisioning
while ! state_done K8S_PROVISIONING; do
  echo "`date`: Waiting for k8s provisioning"
  sleep 10
done


# Get OKE OCID
while ! state_done OKE_OCID; do
  OKE_OCID=$(terraform -chdir="${MTDRWORKSHOP_LOCATION}"/terraform output -json | python "$MTDRWORKSHOP_LOCATION"/utils/python-scripts/process-cluster-ocid-json.py)
  if [[ $OKE_OCID == Error* ]]; then
    echo "$OKE_OCID"
    exit
  fi
    state_set OKE_OCID "$OKE_OCID"
  # Wait for OKE to warm up
done


# Setup Cluster Access
while ! state_done KUBECTL; do
  oci ce cluster create-kubeconfig --cluster-id "$(state_get OKE_OCID)" --file $HOME/.kube/config --region "$(state_get REGION)" --token-version 2.0.0

  cluster_id="$(state_get OKE_OCID)"
  kubectl config set-credentials "user-${cluster_id:(-11)}" --exec-command="kube_token_cache.sh" \
  --exec-arg="ce" \
  --exec-arg="cluster" \
  --exec-arg="generate-token" \
  --exec-arg="--cluster-id" \
  --exec-arg="${cluster_id}" \
  --exec-arg="--region" \
  --exec-arg="$(state_get REGION)"

  state_set_done KUBECTL
done


# Wait for OKE nodes to become ready
while ! state_done BYO_K8S; do
  READY_NODES=`kubectl get nodes | grep Ready | wc -l` || echo 'Ignoring any Error'
  if test "$READY_NODES" -ge 3; then
    echo "3 OKE nodes are ready"
    break
  fi
  echo "Waiting for OKE nodes to become ready"
  sleep 10
done


# Create OKE Namespace
while ! state_done OKE_NAMESPACE; do
  if kubectl create ns mtdrworkshop; then
    state_set_done OKE_NAMESPACE
  else
    echo "Failed to create namespace.  Retrying..."
    sleep 10
  fi
done

# Wait for TO DO User (avoid concurrent kubectl)
while ! state_done TODO_USER; do
  echo "`date`: Waiting for TODO_USER"
  sleep 2
done

state_set_done OKE_SETUP
