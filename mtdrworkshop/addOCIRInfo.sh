#!/bin/bash
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

if [[ $1 == "" ]]
then
  echo MTDRWORKSHOP_OCIR_NAMESPACE not provided
  echo Required arguments are MTDRWORKSHOP_OCIR_NAMESPACE and MTDRWORKSHOP_REPOS_NAME.
  echo Usage example : ./addOCIRInfo.sh axkcsk2aiatb mtdrworkshop.user1/mtdrworkshop
  exit
fi

if [[ $2 == "" ]]
then
  echo MTDRWORKSHOP_REPOS_NAME not provided
  echo Required arguments are MTDRWORKSHOP_OCIR_NAMESPACE and MTDRWORKSHOP_REPOS_NAME.
  echo Usage example : ./addOCIRInfo.sh axkcsk2aiatb mtdrworkshop.user1/mtdrworkshop
  exit
fi

export WORKINGDIR=workingdir
echo WORKINGDIR = $WORKINGDIR

export MTDRWORKSHOP_OCIR_NAMESPACE=$1
echo $MTDRWORKSHOP_OCIR_NAMESPACE | tr -d '"' > $WORKINGDIR/mtdrworkshopocirnamespace.txt
echo MTDRWORKSHOP_OCIR_NAMESPACE... $MTDRWORKSHOP_OCIR_NAMESPACE

export MTDRWORKSHOP_REPOS_NAME=$2
echo $MTDRWORKSHOP_REPOS_NAME | tr -d '"' > $WORKINGDIR/mtdrworkshopreposname.txt
echo MTDRWORKSHOP_REPOS_NAME... $MTDRWORKSHOP_REPOS_NAME
