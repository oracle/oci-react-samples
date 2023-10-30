#!/bin/bash
## MyToDoReact version 2.0.0
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

echo Deleting frontend deployment and service...

kubectl -n mtdrworkshop delete deployment frontendapp-deployment
kubectl -n mtdrworkshop delete service frontendapp-service
