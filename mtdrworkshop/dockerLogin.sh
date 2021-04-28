#!/bin/bash
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

echo Ensure MTDRWORKSHOP_OCIR_AUTHKEY argument is in quotes.
echo Usage example 1: ./dockerLogin.sh foo@bar.com "8nO[BKNU5iwasdf2xeefU;yl"
echo Usage example 2: ./dockerLogin.sh oracleidentitycloudservice/foo@bar.com "8nO[BKNU5iwasdf2xeefU;yl"

export WORKINGDIR=workingdir
echo WORKINGDIR = $WORKINGDIR

if [[ $1 == "" ]]
then
  echo MTDRWORKSHOP_OCIR_USER not provided
  echo Required arguments are MTDRWORKSHOP_OCIR_USER and MTDRWORKSHOP_OCIR_AUTHKEY.
  echo Usage example : ./dockerLogin.sh foo@bar.com "8nO[BKNU5iwasdf2xeefU;yl"
  exit
fi
if [[ $2 == "" ]]
then
  echo MTDRWORKSHOP_OCIR_AUTHKEY not provided
  echo Required arguments are MTDRWORKSHOP_OCIR_USER and MTDRWORKSHOP_OCIR_AUTHKEY.
  echo Usage example : ./dockerLogin.sh foo@bar.com "8nO[BKNU5iwasdf2xeefU;yl"
  exit
fi

export MTDRWORKSHOP_OCIR_USER=$1
echo $MTDRWORKSHOP_OCIR_USER | tr -d '"' > $WORKINGDIR/mtdrworkshopociruser.txt
echo MTDRWORKSHOP_OCIR_USER... $MTDRWORKSHOP_OCIR_USER

export MTDRWORKSHOP_OCIR_AUTHKEY=$2
echo $MTDRWORKSHOP_OCIR_AUTHKEY | tr -d '"' > $WORKINGDIR/mtdrworkshopocirauthkey.txt
echo MTDRWORKSHOP_OCIR_AUTHKEY... $MTDRWORKSHOP_OCIR_AUTHKEY

export MTDRWORKSHOP_REGION=$(cat $WORKINGDIR/mtdrworkshopregion.txt)
echo MTDRWORKSHOP_REGION... $MTDRWORKSHOP_REGION

export MTDRWORKSHOP_OCIR_NAMESPACE=$(cat $WORKINGDIR/mtdrworkshopocirnamespace.txt)
echo MTDRWORKSHOP_OCIR_NAMESPACE... $MTDRWORKSHOP_OCIR_NAMESPACE

export MTDRWORKSHOP_REPOS_NAME=$(cat $WORKINGDIR/mtdrworkshopreposname.txt)
echo MTDRWORKSHOP_REPOS_NAME... $MTDRWORKSHOP_REPOS_NAME


#export DOCKER_REGISTRY="<region-key>.ocir.io/<object-storage-namespace>/<firstname.lastname>/<repo-name>"
# example... export DOCKER_REGISTRY=us-ashburn-1.ocir.io/aqsghou34ag/paul.parkinson/myreponame
export DOCKER_REGISTRY=$MTDRWORKSHOP_REGION.ocir.io/$MTDRWORKSHOP_OCIR_NAMESPACE/$MTDRWORKSHOP_REPOS_NAME
echo $DOCKER_REGISTRY | tr -d '"' > $WORKINGDIR/mtdrworkshopdockerregistry.txt
echo DOCKER_REGISTRY... $DOCKER_REGISTRY

# example... docker login REGION-ID.ocir.io -u <tenant name>/<username>
# example... docker login REGION-ID.ocir.io -u OBJECT-STORAGE-NAMESPACE/USERNAME
echo docker login $MTDRWORKSHOP_REGION.ocir.io -u $MTDRWORKSHOP_OCIR_NAMESPACE/$MTDRWORKSHOP_OCIR_USER -p $MTDRWORKSHOP_OCIR_AUTHKEY
docker login $MTDRWORKSHOP_REGION.ocir.io -u $MTDRWORKSHOP_OCIR_NAMESPACE/$MTDRWORKSHOP_OCIR_USER -p $MTDRWORKSHOP_OCIR_AUTHKEY
