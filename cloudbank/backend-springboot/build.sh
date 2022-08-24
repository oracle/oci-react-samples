#!/bin/bash
## Copyright (c) 2021 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

# building image string
if [ -z "$BACKEND_IMAGE" ]; then
  REGISTRY=$(state_get .lab.docker_registry)
  IMG=$(state_get .app.backend.image.name)
  VERSION=$(state_get .app.backend.image.version)
  export BACKEND_IMAGE="$REGISTRY/$IMG:$VERSION"
fi

# package
mvn clean package spring-boot:repackage

# build
docker build -t $BACKEND_IMAGE .

# push
docker push "$BACKEND_IMAGE"

# cleanup
if [  $? -eq 0 ]; then
    docker rmi "$BACKEND_IMAGE"
fi


