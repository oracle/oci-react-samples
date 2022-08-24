#!/bin/bash
## Copyright (c) 2021 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

# Retrieve image
if [ -z "$FRONTEND_IMAGE" ]; then
  DOCKER_REGISTRY=$(state_get .lab.docker_registry)
  IMG=$(state_get .app.frontend.image.name)
  VERSION=$(state_get .app.frontend.image.version)
  export FRONTEND_IMAGE="$DOCKER_REGISTRY/$IMG:$VERSION"
fi

# Build Application
mvn clean package
docker build -t "$FRONTEND_IMAGE" .

# Push to Registry
docker push "$FRONTEND_IMAGE"
if [  $? -eq 0 ]; then
    docker rmi "$FRONTEND_IMAGE"
fi
