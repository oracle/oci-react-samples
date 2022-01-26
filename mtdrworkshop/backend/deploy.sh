#!/bin/bash
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/
SCRIPT_DIR=$(dirname $0)
export DOCKER_REGISTRY=$(state_get DOCKER_REGISTRY)
echo "Creating helidon deployment and service"
export CURRENTTIME=$( date '+%F_%H:%M:%S' )
echo CURRENTTIME is $CURRENTTIME  ...this will be appended to generated deployment yaml
cp src/main/k8s/application.yaml todolistapp-helidon-se-deployment-$CURRENTTIME.yaml
#may hit sed incompat issue with mac
sed -i "s|%DOCKER_REGISTRY%|${DOCKER_REGISTRY}|g" todolistapp-helidon-se-deployment-$CURRENTTIME.yaml
#kubectl apply -f $SCRIPT_DIR/todolistapp-helidon-se-deployment-$CURRENTTIME.yaml 


if [ -z "$1" ]; then
    kubectl apply -f $SCRIPT_DIR/todolistapp-helidon-se-deployment-$CURRENTTIME.yaml -n msdataworkshop
else
    kubectl apply -f <(istioctl kube-inject -f $SCRIPT_DIR/todolistapp-helidon-se-deployment-$CURRENTTIME.yaml) -n msdataworkshop
fi

#kubectl apply -f $SCRIPT_DIR/order-service.yaml -n msdataworkshop

#kubectl create -f $SCRIPT_DIR/todolistapp-helidon-se-service.yaml  -n todoapplication
