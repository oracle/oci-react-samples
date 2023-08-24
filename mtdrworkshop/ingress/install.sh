#!/bin/bash

# use helm to add ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# update 
helm repo update

# create namespace
kubectl create namespace ws-ingress

# install
helm install nginx-ingress ingress-nginx/ingress-nginx -n ws-ingress --values config.yaml