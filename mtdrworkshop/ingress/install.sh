#!/bin/bash

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --set controller.service.externalTrafficPolicy=Local \
  --namespace ingress-nginx --create-namespace
  