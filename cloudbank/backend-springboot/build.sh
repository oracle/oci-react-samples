#!/bin/bash
## Copyright (c) 2021 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

# logfile
mkdir -p $CB_STATE_DIR/logs/app-backend
package_logfile=$CB_STATE_DIR/logs/app-backend/$CURRENT_TIME-app-build-backend.log
push_logfile=$CB_STATE_DIR/logs/app-backend/$CURRENT_TIME-app-push-backend.log
touch $package_logfile
touch $push_logfile

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

# build
echo "Building image..."
docker build -t $BACKEND_IMAGE . --quiet
echo ""

# push
echo "Pushing image to OCIR..."
docker push "$BACKEND_IMAGE" > $push_logfile

# cleanup
docker rmi "$BACKEND_IMAGE"


