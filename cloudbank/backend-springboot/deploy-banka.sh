#!/bin/bash
## Copyright (c) 2022 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

# building image string
if [ -z "$BACKEND_IMAGE" ]; then
  DOCKER_REGISTRY=$(state_get .lab.docker_registry)
  IMG=$(state_get .app.backend.image.name)
  VERSION=$(state_get .app.backend.image.version)
  export BACKEND_IMAGE="$DOCKER_REGISTRY/$IMG:$VERSION"
fi

# other
BANK_NAME=$(state_get .app.services.banka)
DB_WALLET_SECRET=$(state_get .app.secrets.DB_WALLET_SECRET)
DB_NAME=$(state_get .lab.db.name)

echo -n create banka deployment and service...
export CURRENTTIME=generated

# resource locations
BANKA_DEPLOYMENT=$CB_STATE_DIR/generated/banka-deployment-$CURRENTTIME.yaml
BANKA_SERVICE=$CB_STATE_DIR/generated/banka-service.yaml

# generate resource files
cp $CB_ROOT_DIR/backend-springboot/bank-deployment.yaml $BANKA_DEPLOYMENT
cp $CB_ROOT_DIR/backend-springboot/banka-service.yaml $BANKA_SERVICE

# update resource files
sed -e  "s|%BACKEND_IMAGE%|${BACKEND_IMAGE}|g" $BANKA_DEPLOYMENT > /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKA_DEPLOYMENT
sed -e  "s|%BANK_NAME%|${BANK_NAME}|g" $BANKA_DEPLOYMENT > /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKA_DEPLOYMENT


sed -e  "s|%db-wallet-secret%|${DB_WALLET_SECRET}|g" $BANKA_DEPLOYMENT > /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKA_DEPLOYMENT
sed -e  "s|%PDB_NAME%|${DB_NAME}|g" $BANKA_DEPLOYMENT > /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKA_DEPLOYMENT


sed -e  "s|%USER%|bankauser|g" $BANKA_DEPLOYMENT > /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKA_DEPLOYMENT

sed -e  "s|%localbankqueueschema%|aquser|g" $BANKA_DEPLOYMENT > /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKA_DEPLOYMENT
sed -e  "s|%localbankqueuename%|BANKAQUEUE|g" $BANKA_DEPLOYMENT> /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKA_DEPLOYMENT
sed -e  "s|%banksubscribername%|banka_service|g" $BANKA_DEPLOYMENT > /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKA_DEPLOYMENT

sed -e  "s|%remotebankqueueschema%|aquser|g" $BANKA_DEPLOYMENT > /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKA_DEPLOYMENT
sed -e  "s|%remotebankqueuename%|BANKBQUEUE|g" $BANKA_DEPLOYMENT > /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKA_DEPLOYMENT

# apply resource files
echo "DONE"
kubectl apply -f $BANKA_DEPLOYMENT
kubectl apply -f $BANKA_SERVICE
echo ""
