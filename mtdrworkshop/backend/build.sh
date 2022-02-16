#!/bin/bash
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

SCRIPT_DIR=$(dirname $0)

IMAGE_NAME=todolistapp-helidon-se
IMAGE_VERSION=0.1

if [ -z "$DOCKER_REGISTRY" ]; then
    echo "DOCKER_REGISTRY not set. Will get it with state_get"
  export DOCKER_REGISTRY=$(state_get DOCKER_REGISTRY)
fi

if [ -z "$DOCKER_REGISTRY" ]; then
    echo "Error: DOCKER_REGISTRY env variable needs to be set!"
    exit 1
fi

export IMAGE=${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_VERSION}
mvn install
docker build -f src/main/docker/Dockerfile -t $IMAGE .
# mvn package docker:build

# if [ $DOCKERBUILD_RETCODE -ne 0 ]; then
if [ $? -ne 0 ]; then
    exit 1
fi
docker push $IMAGE
# if [  $? -eq 0 ]; then
#     docker rmi ${IMAGE}
# fi
