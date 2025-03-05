#!/bin/bash
# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Make sure this is run via source or .
if ! (return 0 2>/dev/null); then
  echo "ERROR: Usage 'source env.sh'"
  exit
fi

# POSIX compliant find and replace
function sed_i(){
  local OP="$1"
  local FILE="$2"
  sed -e "$OP" "$FILE" >"/tmp/$FILE"
  mv -- "/tmp/$FILE" "$FILE"
}
export -f sed_i

# Java Home
# -d true if file is a directory, so it's testing if this directory exists, if it does
# we are on Mac doing local dev
function set_javahome(){
  if test -d ~/graalvm-ce-java11-20.1.0/Contents/Home/bin; then
    # We are on Mac doing local dev
    export JAVA_HOME=~/graalvm-ce-java11-20.1.0/Contents/Home;
  else
    # Assume linux
    export JAVA_HOME=~/graalvm-ce-java11-20.1.0
  fi
  export PATH=$JAVA_HOME/bin:$PATH
}

#set mtdrworkshop_location
export MTDRWORKSHOP_LOCATION="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $MTDRWORKSHOP_LOCATION
echo "MTDRWORKSHOP_LOCATION: $MTDRWORKSHOP_LOCATION"


JAVA_TEST=`which java`
if [ -n $JAVA_TEST ]; then
  echo "JAVA Found: $JAVA_TEST"
else
  set_javahome
fi

#state directory
if test -d ~/mtdrworkshop-state; then
  export MTDRWORKSHOP_STATE_HOME=~/mtdrworkshop-state
else
  export MTDRWORKSHOP_STATE_HOME=$MTDRWORKSHOP_LOCATION
fi
echo "MTDRWORKSOP_STATE_HOME: $MTDRWORKSHOP_STATE_HOME"
#Log Directory
export MTDRWORKSHOP_LOG=$MTDRWORKSHOP_STATE_HOME/log
mkdir -p $MTDRWORKSHOP_LOG

source $MTDRWORKSHOP_LOCATION/utils/state-functions.sh

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
