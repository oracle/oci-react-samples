#!/bin/bash
## MyToDoReact version 1.0.
##
## Copyright (c) 2021 Oracle, Inc.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

echo download and extract GraalVM...
curl -sLO https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-20.1.0/graalvm-ce-java11-linux-amd64-20.1.0.tar.gz
gunzip graalvm-ce-java11-linux-amd64-20.1.0.tar.gz
tar xvf graalvm-ce-java11-linux-amd64-20.1.0.tar
rm graalvm-ce-java11-linux-amd64-20.1.0.tar
mv graalvm-ce-java11-20.1.0 ~/

echo ~/graalvm-ce-java11-20.1.0 > $WORKINGDIR/mtdrworkshopgraalvmhome.txt
