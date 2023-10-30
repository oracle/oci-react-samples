#!/bin/bash
## MyToDoReact version 2.0.0
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

SCRIPT_DIR=$(dirname $0)

# set vars
source set.sh

docker build -t $IMAGE .

# if [ $DOCKERBUILD_RETCODE -ne 0 ]; then
if [ $? -ne 0 ]; then
    exit 1
fi
docker push $IMAGE
# if [  $? -eq 0 ]; then
#     docker rmi ${IMAGE}
# fi
