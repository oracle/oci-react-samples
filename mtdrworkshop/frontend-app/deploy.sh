#!/bin/bash
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/
SCRIPT_DIR=$(dirname $0)

echo "Creating frontend deployment and service"
export CURRENTTIME=$( date '+%F_%H:%M:%S' )
YAML_NAME=manifest-$CURRENTTIME.yaml
export DOCKER_REGISTRY=$(state_get DOCKER_REGISTRY)





echo CURRENTTIME is $CURRENTTIME  ...this will be appended to generated deployment yaml
cp kubernetes/manifest.yaml "$YAML_NAME"
#may hit sed incompat issue with mac
sed -i "s|%DOCKER_REGISTRY%|${DOCKER_REGISTRY}|g" "$YAML_NAME"
#kubectl apply -f $SCRIPT_DIR/"$YAML_NAME" 

sed -e "s|%DOCKER_REGISTRY%|${DOCKER_REGISTRY}|g" "$YAML_NAME" > /tmp/"$YAML_NAME"
mv -- /tmp/"$YAML_NAME" "$YAML_NAME"
sed -e "s|%DOCKER_IMAGE%|${IMAGE_NAME}|g" "$YAML_NAME" > /tmp/"$YAML_NAME"
mv -- /tmp/"$YAML_NAME" "$YAML_NAME"
sed -e "s|%DOCKER_IMAGE_TAG%|${IMAGE_VERSION}|g" "$YAML_NAME" > /tmp/"$YAML_NAME"
mv -- /tmp/"$YAML_NAME" "$YAML_NAME"

kubectl apply -f $SCRIPT_DIR/"$YAML_NAME" -n mtdrworkshop