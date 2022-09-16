#!/bin/bash

aksName=aks-wasm-demo
rgName=rg-cloudland-2022
az aks nodepool add --cluster-name $aksName -g $rgName -n wasmpool -c 1 --workload-runtime wasmwasi

