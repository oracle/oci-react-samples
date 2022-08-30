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
BANK_NAME=$(state_get .app.services.bankb)
DB_WALLET_SECRET=$(state_get .app.secrets.DB_WALLET_SECRET)
DB_NAME=$(state_get .lab.db.name)

echo -n create bankb deployment and service...
export CURRENTTIME=generated

# resource locations
BANKB_DEPLOYMENT=$CB_STATE_DIR/generated/bankb-deployment-$CURRENTTIME.yaml
BANKB_SERVICE=$CB_STATE_DIR/generated/bankb-service.yaml

# generate resource files
cp $CB_ROOT_DIR/backend-springboot/bank-deployment.yaml $BANKB_DEPLOYMENT
cp $CB_ROOT_DIR/backend-springboot/bankb-service.yaml $BANKB_SERVICE

# update resource files
sed -e  "s|%BACKEND_IMAGE%|${BACKEND_IMAGE}|g" $BANKB_DEPLOYMENT > /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKB_DEPLOYMENT
sed -e  "s|%BANK_NAME%|${BANK_NAME}|g" $BANKB_DEPLOYMENT > /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKB_DEPLOYMENT


sed -e  "s|%db-wallet-secret%|${DB_WALLET_SECRET}|g" $BANKB_DEPLOYMENT > /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKB_DEPLOYMENT
sed -e  "s|%PDB_NAME%|${DB_NAME}|g" $BANKB_DEPLOYMENT > /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKB_DEPLOYMENT

sed -e  "s|%USER%|bankbuser|g" $BANKB_DEPLOYMENT > /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKB_DEPLOYMENT

sed -e  "s|%localbankqueueschema%|aquser|g" $BANKB_DEPLOYMENT > /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKB_DEPLOYMENT
sed -e  "s|%localbankqueuename%|BANKBQUEUE|g" $BANKB_DEPLOYMENT> /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKB_DEPLOYMENT
sed -e  "s|%banksubscribername%|bankb_service|g" $BANKB_DEPLOYMENT > /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKB_DEPLOYMENT

sed -e  "s|%remotebankqueueschema%|aquser|g" $BANKB_DEPLOYMENT > /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKB_DEPLOYMENT
sed -e  "s|%remotebankqueuename%|BANKAQUEUE|g" $BANKB_DEPLOYMENT > /tmp/bank-deployment-$CURRENTTIME.yaml
mv -- /tmp/bank-deployment-$CURRENTTIME.yaml $BANKB_DEPLOYMENT

# apply resource files
echo "DONE"
kubectl apply -f $BANKB_DEPLOYMENT
kubectl apply -f $BANKB_SERVICE
echo ""
