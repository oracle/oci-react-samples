#!/bin/bash
## MyToDoReact version 2.0.0
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/
SCRIPT_DIR=$(dirname $0)

echo "Creating helidon deployment and service"

# set vars
source set.sh

export CURRENTTIME=$( date '+%F_%H:%M:%S' )
YAML_NAME=manifest-$CURRENTTIME.yaml

echo CURRENTTIME is $CURRENTTIME  ...this will be appended to generated deployment yaml
cp src/main/k8s/manifest.yaml "$YAML_NAME"
#may hit sed incompat issue with mac
sed -i "s|%DOCKER_REGISTRY%|${DOCKER_REGISTRY}|g" "$YAML_NAME"
#kubectl apply -f $SCRIPT_DIR/"$YAML_NAME" 

sed -e "s|%DOCKER_REGISTRY%|${DOCKER_REGISTRY}|g" "$YAML_NAME" > /tmp/"$YAML_NAME"
mv -- /tmp/"$YAML_NAME" "$YAML_NAME"
sed -e "s|%DOCKER_IMAGE%|${IMAGE_NAME}|g" "$YAML_NAME" > /tmp/"$YAML_NAME"
mv -- /tmp/"$YAML_NAME" "$YAML_NAME"
sed -e "s|%DOCKER_IMAGE_TAG%|${IMAGE_VERSION}|g" "$YAML_NAME" > /tmp/"$YAML_NAME"
mv -- /tmp/"$YAML_NAME" "$YAML_NAME"
sed -e "s|%TODO_PDB_NAME%|${TODO_PDB_NAME}|g" "$YAML_NAME" > /tmp/"$YAML_NAME"
mv -- /tmp/"$YAML_NAME" "$YAML_NAME"
sed -e "s|%OCI_REGION%|${OCI_REGION}|g" "$YAML_NAME" > /tmp/"$YAML_NAME"
mv -- /tmp/"$YAML_NAME" "$YAML_NAME"


if [ -z "$1" ]; then
    kubectl apply -f $SCRIPT_DIR/"$YAML_NAME" -n mtdrworkshop
else
    kubectl apply -f <(istioctl kube-inject -f $SCRIPT_DIR/"$YAML_NAME") -n mtdrworkshop
fi

#kubectl apply -f $SCRIPT_DIR/order-service.yaml -n mtdrworkshop

#kubectl create -f $SCRIPT_DIR/todolistapp-helidon-se-service.yaml  -n todoapplication
