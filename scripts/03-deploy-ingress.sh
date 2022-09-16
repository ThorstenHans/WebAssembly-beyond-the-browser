#!/bin/bash

echo "Adding Bitnami repo to helm"
helm repo add bitnami https://charts.bitnami.com/bitnami

echo "Updating helm repos"
helm repo update

echo "Reading Wasm node ip address (label beta.kubernetes.io/arch=wasm32-wagi must be set on node"
wasmNodeIp=$(kubectl get node --selector=beta.kubernetes.io/arch=wasm32-wagi -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

echo "Will update ingress-values.yml and set Wasm node IP to" $wasmNodeIp
sed -i '' 's/WASM_NODE_IP/'"$wasmNodeIp"'/g' ./ingress-values.yml

echo "Will install NGINX ingress"
helm install nginx bitnami/nginx -f ./ingress-values.yml
