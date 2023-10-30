#!/bin/bash
## MyToDoReact version 2.0.0
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

echo Deleting backend deployment and service...

kubectl -n mtdrworkshop delete deployment backend-deployment
kubectl -n mtdrworkshop delete service backend-service
