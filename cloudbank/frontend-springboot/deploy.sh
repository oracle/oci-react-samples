#!/bin/bash
## Copyright (c) 2022 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

CLOUDBANK_USERNAME=$(state_get .app.frontend.user)
CLOUDBANK_SERVICE_NAMESPACE=$(state_get .namespace)
CLOUDBANK_SERVICE_BANKA=$(state_get .app.services.banka)
CLOUDBANK_SERVICE_BANKB=$(state_get .app.services.bankb)
CLOUDBANK_SERVICE_PORT=$(state_get .app.services.port)
CLOUDBANK_CREDENTIALS_SECRET_KEY=$(state_get .app.secrets.FRONTEND_CREDENTIALS.key)
CLOUDBANK_CREDENTIALS_SECRET_NAME=$(state_get .app.secrets.FRONTEND_CREDENTIALS.name)

# Build APIs
CLOUDBANK_APIS_BANKA=http://${CLOUDBANK_SERVICE_BANKA}.${CLOUDBANK_SERVICE_NAMESPACE}:${CLOUDBANK_SERVICE_PORT}
CLOUDBANK_APIS_BANKB=http://${CLOUDBANK_SERVICE_BANKB}.${CLOUDBANK_SERVICE_NAMESPACE}:${CLOUDBANK_SERVICE_PORT}
export CURRENTTIME=generated

# Retrieve image
if [ -z "$FRONTEND_IMAGE" ]; then
  DOCKER_REGISTRY=$(state_get .lab.docker_registry)
  FRONTEND_IMAGE_VALUE=$(state_get .app.frontend.image.name)
  FRONTEND_IMAGE_VERSION=$(state_get .app.frontend.image.version)
  export FRONTEND_IMAGE="${DOCKER_REGISTRY}/${FRONTEND_IMAGE_VALUE}:${FRONTEND_IMAGE_VERSION}"
fi

echo "creating frontend deployment and service..."
# resource locations and copying from template
FRONTEND_MANIFEST=$CB_STATE_DIR/generated/frontend-manifest.yaml
cp $CB_ROOT_DIR/frontend-springboot/deployment.yaml $FRONTEND_MANIFEST

FRONTEND_SERVICE=$CB_STATE_DIR/generated/frontend-service.yaml
cp $CB_ROOT_DIR/frontend-springboot/service.yaml $FRONTEND_SERVICE

# Replacing Container Image
sed -e  "s|%CLOUDBANK_APP_IMAGE%|$FRONTEND_IMAGE|g" $FRONTEND_MANIFEST > /tmp/manifest-$CURRENTTIME.yaml
mv -- /tmp/manifest-$CURRENTTIME.yaml $FRONTEND_MANIFEST

# Replacing Auth Credentials

sed -e  "s|%CLOUDBANK_SECURITY_PWD_SECRET_NAME%|$CLOUDBANK_CREDENTIALS_SECRET_NAME|g" $FRONTEND_MANIFEST > /tmp/manifest-$CURRENTTIME.yaml
mv -- /tmp/manifest-$CURRENTTIME.yaml $FRONTEND_MANIFEST

sed -e  "s|%CLOUDBANK_SECURITY_PWD_SECRET_KEY%|$CLOUDBANK_CREDENTIALS_SECRET_KEY|g" $FRONTEND_MANIFEST > /tmp/manifest-$CURRENTTIME.yaml
mv -- /tmp/manifest-$CURRENTTIME.yaml $FRONTEND_MANIFEST

sed -e  "s|%CLOUDBANK_SECURITY_USERNAME%|$CLOUDBANK_USERNAME|g" $FRONTEND_MANIFEST > /tmp/manifest-$CURRENTTIME.yaml
mv -- /tmp/manifest-$CURRENTTIME.yaml $FRONTEND_MANIFEST


# Replacing API Endpoints
sed -e  "s|%CLOUDBANK_APIS_BANKA%|$CLOUDBANK_APIS_BANKA|g" $FRONTEND_MANIFEST > /tmp/manifest-$CURRENTTIME.yaml
mv -- /tmp/manifest-$CURRENTTIME.yaml $FRONTEND_MANIFEST

sed -e  "s|%CLOUDBANK_APIS_BANKB%|$CLOUDBANK_APIS_BANKB|g" $FRONTEND_MANIFEST > /tmp/manifest-$CURRENTTIME.yaml
mv -- /tmp/manifest-$CURRENTTIME.yaml $FRONTEND_MANIFEST

# Apply Manifest
kubectl apply -f $FRONTEND_MANIFEST
kubectl apply -f $FRONTEND_SERVICE

