#!/bin/bash
# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Make sure this is run via source or .
if ! (return 0 2>/dev/null); then
  echo "ERROR: Usage 'source env.sh'"
  exit
fi

# ######################################################
# set mtdrworkshop_home to where the current directory is (under ~/../mtdrtodo)
# command: source oci-react-samples/mtdrworkshop/env.sh
# set mtdrworkshop_location to the location of this script
export MTDRWORKSHOP_LOCATION="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# source state-functions
source $MTDRWORKSHOP_LOCATION/utils/state-functions.sh

if ! state_set_done STATE_HOME; then
  state_set STATE_HOME "${pwd}"
fi 

export MTDRWORKSHOP_HOME="$(state_get STATE_HOME)"
export MTDRWORKSHOP_STATE_HOME=$MTDRWORKSHOP_HOME/state
export MTDRWORKSHOP_LOG=$MTDRWORKSHOP_HOME/state/log

# configure env.sh to run everytime cloud shell is start up
# only if it does not already exist
if ! grep -q "$MTDRWORKSHOP_LOCATION"/env.sh ~/.bashrc; then
  echo source "$MTDRWORKSHOP_LOCATION"/env.sh >> ~/.bashrc
  cp ~/.bashrc ~/.bashrc.copy
fi


mkdir -p $MTDRWORKSHOP_STATE_HOME
mkdir -p $MTDRWORKSHOP_LOG
cd $MTDRWORKSHOP_LOCATION
echo "MTDRWORKSHOP_LOCATION: $MTDRWORKSHOP_LOCATION"
echo "MTDRWORKSOP_STATE_HOME: $MTDRWORKSHOP_STATE_HOME"


# ######################################################
# Java Home
# -d true if file is a directory, so it's testing if this directory exists, if it does
# we are on Mac doing local dev
if test -d ~/graalvm-ce-java11-20.1.0/Contents/Home/bin; then
  # We are on Mac doing local dev
  export JAVA_HOME=~/graalvm-ce-java11-20.1.0/Contents/Home;
else
  # Assume linux
  export JAVA_HOME=~/graalvm-ce-java11-20.1.0
fi
export PATH=$JAVA_HOME/bin:$PATH


# ######################################################
# SHORTCUT ALIASES AND UTILS...
alias k='kubectl'
alias kt='kubectl --insecure-skip-tls-verify'
alias pods='kubectl get po --all-namespaces'
alias services='kubectl get services --all-namespaces'
alias gateways='kubectl get gateways --all-namespaces'
alias secrets='kubectl get secrets --all-namespaces'
alias ingresssecret='kubectl get secrets --all-namespaces | grep istio-ingressgateway-certs'
alias virtualservices='kubectl get virtualservices --all-namespaces'
alias deployments='kubectl get deployments --all-namespaces'
alias mtdrworkshop='echo deployments... ; deployments|grep mtdrworkshop ; echo pods... ; pods|grep mtdrworkshop ; echo services... ; services | grep mtdrworkshop ; echo secrets... ; secrets|grep mtdrworkshop ; echo "other shortcut commands... most can take partial podname as argument, such as [logpod front] or [deletepod order]...  pods  services secrets deployments " ; ls $MTDRWORKSHOP_LOCATION/utils/'

export PATH=$PATH:$MTDRWORKSHOP_LOCATION/utils/
