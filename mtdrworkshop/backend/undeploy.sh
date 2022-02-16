#!/bin/bash
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

echo delete frontend deployment and service...

kubectl -n mtdrworkshop delete deployment todolistapp-helidon-se-deployment 
kubectl -n mtdrworkshop delete service todolistapp-helidon-se-service
