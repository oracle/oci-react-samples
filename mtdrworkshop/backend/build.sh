#!/bin/bash
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

SCRIPT_DIR=$(dirname $0)

# set vars
source set.sh

mvn clean package
docker build -f src/main/docker/Dockerfile -t $IMAGE .

if [ $? -ne 0 ]; then
    exit 1
fi
docker push $IMAGE
