#!/bin/bash
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

echo ________________________________________
echo Deletting resources
echo ________________________________________

export WORKINGDIR=~/mtdrworkshop/workingdir
echo WORKINGDIR = $WORKINGDIR

export MTDRWORKSHOP_COMPARTMENT_ID=$(cat $WORKINGDIR/mtdrworkshopcompartmentid.txt)
export MTDRDB_OCID=$(cat $WORKINGDIR/mtdrworkshopdbid.txt)
export DOCKER_REGISTRY=$(cat $WORKINGDIR/mtdrworkshopdockerregistry.txt)
export MTDRGTW_OCID=$(cat $WORKINGDIR/mtdrworkshopgatewayid.txt)
export MTDRWORKSHOP_OKE_CLUSTER=$(cat $WORKINGDIR/mtdrworkshopclusterid.txt)


echo Deleting ADB $MTDRDB ...
oci db autonomous-database delete --autonomous-database-id $MTDRDB_OCID --force

echo Deleting the OKE cluster $MTDRWORKSHOP_OKE_CLUSTER ...
oci ce cluster delete --cluster-id $MTDRWORKSHOP_OKE_CLUSTER --force

echo Deleting API-gateway $MTDRGTW_OCID ...
oci api-gateway gateway delete --gateway-id  $MTDRGTW_OCID --force

echo Deleting Bucket ...
oci os bucket delete --bucket-name mtdrworkshop --force

echo Deleting Repository $DOCKER_REGISTRY ...
oci artifacts container repository delete --repository-id $DOCKER_REGISTRY
