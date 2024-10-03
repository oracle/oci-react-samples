#!/bin/bash

## MyToDoReact version 2.0.0
##
## Copyright (c) 2024 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as
## shown at https://oss.oracle.com/licenses/upl/


export IMAGE_NAME=todolistapp-springboot
export IMAGE_VERSION=0.1

# Requires
# export DOCKER_REGISTRY=<registry>

if [ -z "$DOCKER_REGISTRY" ]; then
    echo "DOCKER_REGISTRY not set. Will get it with state_get"
  export DOCKER_REGISTRY=$(state_get DOCKER_REGISTRY)
fi

if [ -z "$DOCKER_REGISTRY" ]; then
    echo "Error: DOCKER_REGISTRY env variable needs to be set!"
    exit 1
fi
export IMAGE=${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_VERSION}

mvn clean package spring-boot:repackage
docker buildx build --platform linux/amd64 -f Dockerfile -t $IMAGE .

docker push $IMAGE
if [  $? -eq 0 ]; then
    docker rmi "$IMAGE"
fi