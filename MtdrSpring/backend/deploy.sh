#!/bin/bash

#/**
#* Copyright (c) 2024 Oracle and/or its affiliates.

#* The Universal Permissive License (UPL), Version 1.0

#* Subject to the condition set forth below, permission is hereby granted to any
#* person obtaining a copy of this software, associated documentation and/or data
#* (collectively the "Software"), free of charge and under any and all copyright
#* rights in the Software, and any and all patent rights owned or freely
#* licensable by each licensor hereunder covering either (i) the unmodified
#* Software as contributed to or provided by such licensor, or (ii) the Larger
#* Works (as defined below), to deal in both

#* (a) the Software, and
#* (b) any piece of software and/or hardware listed in the lrgrwrks.txt file if
#* one is included with the Software (each a "Larger Work" to which the Software
#* is contributed by such licensors),

#* without restriction, including without limitation the rights to copy, create
#* derivative works of, display, perform, and distribute the Software and make,
#* use, sell, offer for sale, import, export, have made, and have sold the
#* Software and the Larger Work(s), and to sublicense the foregoing rights on
#* either these or other terms.

#* This license is subject to the following condition:
#* The above copyright notice and either this complete permission notice or at
#* a minimum a reference to the UPL must be included in all copies or
#* substantial portions of the Software.

#* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#* SOFTWARE.
#
#*/

SCRIPT_DIR=$(dirname $0)

# Requires
# export TODO_PDB_NAME=<database-name>
# export DOCKER_REGISTRY=<registry>
# export UI_USERNAME=admin

if [ -z "$TODO_PDB_NAME" ]; then
    echo "TODO_PDB_NAME not set. Will get it with state_get"
  export TODO_PDB_NAME=$(state_get MTDR_DB_NAME)
fi
if [ -z "$TODO_PDB_NAME" ]; then
    echo "Error: TODO_PDB_NAME env variable needs to be set!"
    exit 1
fi

if [ -z "$DOCKER_REGISTRY" ]; then
    echo "DOCKER_REGISTRY not set. Will get it with state_get"
  export DOCKER_REGISTRY=$(state_get DOCKER_REGISTRY)
fi

if [ -z "$DOCKER_REGISTRY" ]; then
    echo "Error: DOCKER_REGISTRY env variable needs to be set!"
    exit 1
fi

if [ -z "$UI_USERNAME" ]; then
    echo "UI_USERNAME not set. Will get it with state_get"
  export UI_USERNAME=$(state_get UI_USERNAME)
fi

if [ -z "$UI_USERNAME" ]; then
    echo "Error: UI_USERNAME env variable needs to be set!"
    exit 1
fi

echo "Creating springboot deplyoment and service"
export CURRENTTIME=$( date '+%F_%H:%M:%S' )
echo CURRENTTIME is $CURRENTTIME  ...this will be appended to generated deployment yaml
cp src/main/resources/todolistapp-springboot.yaml todolistapp-springboot-$CURRENTTIME.yaml

sed -i "s|%DOCKER_REGISTRY%|${DOCKER_REGISTRY}|g" todolistapp-springboot-$CURRENTTIME.yaml

sed -e "s|%DOCKER_REGISTRY%|${DOCKER_REGISTRY}|g" todolistapp-springboot-${CURRENTTIME}.yaml > /tmp/todolistapp-springboot-${CURRENTTIME}.yaml
mv -- /tmp/todolistapp-springboot-$CURRENTTIME.yaml todolistapp-springboot-$CURRENTTIME.yaml

sed -e "s|%TODO_PDB_NAME%|${TODO_PDB_NAME}|g" todolistapp-springboot-${CURRENTTIME}.yaml > /tmp/todolistapp-springboot-${CURRENTTIME}.yaml
mv -- /tmp/todolistapp-springboot-$CURRENTTIME.yaml todolistapp-springboot-$CURRENTTIME.yaml

sed -e "s|%UI_USERNAME%|${UI_USERNAME}|g" todolistapp-springboot-${CURRENTTIME}.yaml > /tmp/todolistapp-springboot-$CURRENTTIME.yaml
mv -- /tmp/todolistapp-springboot-$CURRENTTIME.yaml todolistapp-springboot-$CURRENTTIME.yaml

if [ -z "$1" ]; then
    kubectl apply -f $SCRIPT_DIR/todolistapp-springboot-$CURRENTTIME.yaml -n mtdrworkshop
else
    kubectl apply -f <(istioctl kube-inject -f $SCRIPT_DIR/todolistapp-springboot-$CURRENTTIME.yaml) -n mtdrworkshop
fi
