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
if [ -f src/main/react-app/package-lock.json ]; then
  rm src/main/react-app/package-lock.json
fi
echo -n "Building frontend application..."
mvn clean package -q
if [[ "$?" -ne 0 ]] ; then
  echo "FAILED"; exit 1;
else
  echo "DONE"
fi
echo ""


echo "Building image..."
docker build -t "$FRONTEND_IMAGE" . -q
echo ""

# Push to Registry
echo "Pushing image to OCIR..."
docker push "$FRONTEND_IMAGE"
docker rmi "$FRONTEND_IMAGE"
