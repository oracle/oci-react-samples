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
echo -n "Building backend application..."
mvn clean package spring-boot:repackage -q
if [[ "$?" -ne 0 ]] ; then
  echo "FAILED"; exit 1;
else
  echo "DONE"
fi
echo ""

# build
echo "Building image..."
docker build -t $BACKEND_IMAGE . --quiet
echo ""

# push
echo "Pushing image to OCIR..."
docker push "$BACKEND_IMAGE"

# cleanup
docker rmi "$BACKEND_IMAGE"


