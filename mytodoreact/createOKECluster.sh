#!/bin/bash
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

if [[ $1 == "" ]]
then
  echo Required argument MTDRWORKSHOP_COMPARTMENT_ID not provided. The compartmentid can be copied from the OCI Console.
  echo Usage example : ./createOKECluster.sh ocid1.compartment.oc1..aaaaaaaaxbvaatfz6dyfqbxhmasxfyui4rjek5dnzgcbivfwvsho77myfnqq
  echo [optional second argument is for specifying region. The default value is us-ashburn-1]
  exit
fi

echo ________________________________________
echo creating VCN and OKE cluster ...
echo ________________________________________

export WORKINGDIR=workingdir
echo creating working directory $WORKINGDIR to store values...
mkdir $WORKINGDIR


export MTDRWORKSHOP_REGION=$2
if [[ $MTDRWORKSHOP_REGION == "" ]]
then
  echo defaulting to region us-ashburn-1
  export MTDRWORKSHOP_REGION=us-ashburn-1
fi
echo $MTDRWORKSHOP_REGION | tr -d '"' > $WORKINGDIR/mtdrworkshopregion.txt
echo MTDRWORKSHOP_REGION... $MTDRWORKSHOP_REGION


export MTDRWORKSHOP_COMPARTMENT_ID=$1
echo $MTDRWORKSHOP_COMPARTMENT_ID | tr -d '"' > $WORKINGDIR/mtdrworkshopcompartmentid.txt
echo MTDRWORKSHOP_COMPARTMENT_ID... $MTDRWORKSHOP_COMPARTMENT_ID

echo creating vcn...
oci network vcn create --cidr-block 10.0.0.0/16 --compartment-id $MTDRWORKSHOP_COMPARTMENT_ID --display-name "mtdrworkshopvcn" | jq --raw-output '.data | .["id"] ' > $WORKINGDIR/mtdrworkshopvcnid.txt
export MTDRWORKSHOP_VCN_ID=$(cat $WORKINGDIR/mtdrworkshopvcnid.txt)
echo MTDRWORKSHOP_VCN_ID... $MTDRWORKSHOP_VCN_ID

echo creating oke cluster...
oci ce cluster create --compartment-id $MTDRWORKSHOP_COMPARTMENT_ID --kubernetes-version v1.16.8 --name mtdrworkshopcluster --vcn-id $MTDRWORKSHOP_VCN_ID

echo ________________________________________
echo OKE cluster is being provisioned. You will check for status using verifyOKEAndCreateKubeConfig.sh script later...
echo ________________________________________
