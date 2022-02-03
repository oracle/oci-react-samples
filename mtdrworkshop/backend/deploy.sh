#!/bin/bash
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/
SCRIPT_DIR=$(dirname $0)
export DOCKER_REGISTRY=$(state_get DOCKER_REGISTRY)
if [ -z "$TODO_PDB_NAME" ]; then
    echo "TODO_PDB_NAME not set. Will get it with state_get"
  export TODO_PDB_NAME=$(state_get MTDR_DB_NAME)
fi
if [ -z "$TODO_PDB_NAME" ]; then
    echo "Error: TODO_PDB_NAME env variable needs to be set!"
    exit 1
fi
if [ -z "$OCI_REGION" ]; then
    echo "OCI_REGION not set. Will get it with state_get"
    export OCI_REGION=$(state_get REGION)
fi
if [ -z "$OCI_REGION" ]; then
    echo "Error: OCI_REGION env variable needs to be set!"
    exit 1
fi
echo "Creating helidon deployment and service"
export CURRENTTIME=$( date '+%F_%H:%M:%S' )
echo CURRENTTIME is $CURRENTTIME  ...this will be appended to generated deployment yaml
cp src/main/k8s/todolistapp-helidon-se-deployment.yaml todolistapp-helidon-se-deployment-$CURRENTTIME.yaml
#may hit sed incompat issue with mac
sed -i "s|%DOCKER_REGISTRY%|${DOCKER_REGISTRY}|g" todolistapp-helidon-se-deployment-$CURRENTTIME.yaml
#kubectl apply -f $SCRIPT_DIR/todolistapp-helidon-se-deployment-$CURRENTTIME.yaml 

sed -e "s|%DOCKER_REGISTRY%|${DOCKER_REGISTRY}|g" todolistapp-helidon-se-deployment-${CURRENTTIME}.yaml > /tmp/todolistapp-helidon-se-deployment-${CURRENTTIME}.yaml
mv -- /tmp/todolistapp-helidon-se-deployment-$CURRENTTIME.yaml todolistapp-helidon-se-deployment-$CURRENTTIME.yaml
sed -e "s|%TODO_PDB_NAME%|${TODO_PDB_NAME}|g" todolistapp-helidon-se-deployment-${CURRENTTIME}.yaml > /tmp/todolistapp-helidon-se-deployment-${CURRENTTIME}.yaml
mv -- /tmp/todolistapp-helidon-se-deployment-$CURRENTTIME.yaml todolistapp-helidon-se-deployment-$CURRENTTIME.yaml
sed -e "s|%OCI_REGION%|${OCI_REGION}|g" todolistapp-helidon-se-deployment-${CURRENTTIME}.yaml > /tmp/todolistapp-helidon-se-deployment-$CURRENTTIME.yaml
mv -- /tmp/todolistapp-helidon-se-deployment-$CURRENTTIME.yaml todolistapp-helidon-se-deployment-$CURRENTTIME.yaml


if [ -z "$1" ]; then
    kubectl apply -f $SCRIPT_DIR/todolistapp-helidon-se-deployment-$CURRENTTIME.yaml -n mtdrworkshop
else
    kubectl apply -f <(istioctl kube-inject -f $SCRIPT_DIR/todolistapp-helidon-se-deployment-$CURRENTTIME.yaml) -n mtdrworkshop
fi

#kubectl apply -f $SCRIPT_DIR/order-service.yaml -n mtdrworkshop

#kubectl create -f $SCRIPT_DIR/todolistapp-helidon-se-service.yaml  -n todoapplication
