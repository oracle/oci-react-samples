#!/bin/bash

if [ ! -d "$CB_STATE_DIR"/tls ]; then
  mkdir -p "$CB_STATE_DIR/tls"
fi


# generate key and crt
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $CB_STATE_DIR/tls/tls.key -out $CB_STATE_DIR/tls/tls.crt -subj "/CN=cloudbank/O=cloudbank"

# create secret
kubectl create secret tls ssl-certificate-secret --key $CB_STATE_DIR/tls/tls.key --cert $CB_STATE_DIR/tls/tls.crt -n cloudbank

