#!/bin/bash
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

echo ________________________________________
echo verifying OKE cluster creation,  create ~/.kube/config, create mtdrworkshop namespace, and ..../verify
echo ________________________________________

export WORKINGDIR=workingdir
echo WORKINGDIR = $WORKINGDIR

export MTDRWORKSHOP_REGION=$(cat $WORKINGDIR/mtdrworkshopregion.txt)
echo MTDRWORKSHOP_REGION... $MTDRWORKSHOP_REGION

export MTDRWORKSHOP_COMPARTMENT_ID=$(cat $WORKINGDIR/mtdrworkshopcompartmentid.txt)
echo MTDRWORKSHOP_COMPARTMENT_ID... $MTDRWORKSHOP_COMPARTMENT_ID
echo
#oci ce cluster list --compartment-id $MTDRWORKSHOP_COMPARTMENT_ID --lifecycle-state ACTIVE | jq '.data[]  | select(.name == "mtdrworkshopcluster") | .id' | tr -d '"' > $WORKINGDIR/mtdrworkshopclusterid.txt
cat $WORKINGDIR/mtdrworkshopclusterid.txt
export MTDRWORKSHOP_CLUSTER_ID=$(cat $WORKINGDIR/mtdrworkshopclusterid.txt)
echo MTDRWORKSHOP_CLUSTER_ID... $MTDRWORKSHOP_CLUSTER_ID

if [[ $MTDRWORKSHOP_CLUSTER_ID == "" ]]
then
  echo "MTDRWORKSHOP_CLUSTER_ID does not exist. OKE may still be provisioning. Try again or check the OCI console for progress."
else
  export CURRENTTIME=$( date '+%F_%H:%M:%S' )
  echo backing up existing ~/.kube/config, if any, to ~/.kube/config-$CURRENTTIME
  cp ~/.kube/config ~/.kube/config-$CURRENTTIME
  echo creating ~/.kube/config ...
  oci ce cluster create-kubeconfig --cluster-id $MTDRWORKSHOP_CLUSTER_ID --file $HOME/.kube/config --region $MTDRWORKSHOP_REGION --token-version 2.0.0
#  echo create mtdrworkshop namespace...
#  kubectl create ns mtdrworkshop
fi
