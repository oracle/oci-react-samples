#!/bin/bash
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

if [[ $1 == "" ]]
then
  echo Required argument MTDRWORKSHOP_COMPARTMENT_ID not provided. The compartmentid can be copied from the OCI Console.
  echo Usage example : ./setCompartmentId.sh ocid1.compartment.oc1..aaaaaaaaxbvaatfz6dyfqbxhmasxfyui4rjek5dnzgcbivfwvsho77myfnqq us-ashburn-1
  exit
fi

if [[ $2 == "" ]]
then
  echo Required argument $MTDRWORKSHOP_REGION not provided. The region id can be copied from the OCI Console.
  echo Usage example : ./setCompartmentId.sh ocid1.compartment.oc1..aaaaaaaaxbvaatfz6dyfqbxhmasxfyui4rjek5dnzgcbivfwvsho77myfnqq us-ashburn-1
  exit
fi

echo ________________________________________
echo setting compartmentid and region ...
echo ________________________________________

export WORKINGDIR=workingdir
echo creating working directory $WORKINGDIR to store values...
mkdir $WORKINGDIR

export MTDRWORKSHOP_REGION=$2
echo $MTDRWORKSHOP_REGION | tr -d '"' > $WORKINGDIR/mtdrworkshopregion.txt
echo MTDRWORKSHOP_REGION... $MTDRWORKSHOP_REGION

export MTDRWORKSHOP_COMPARTMENT_ID=$1
echo $MTDRWORKSHOP_COMPARTMENT_ID | tr -d '"' > $WORKINGDIR/mtdrworkshopcompartmentid.txt
echo MTDRWORKSHOP_COMPARTMENT_ID... $MTDRWORKSHOP_COMPARTMENT_ID
