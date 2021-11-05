#!/bin/bash

K3D_CLUSTER_NAME=${K3D_CLUSTER_NAME:-"local"}
KIND_CLUSTER_NAME=${KIND_CLUSTER_NAME:-"kind"}

if [ "$(k3d cluster list | grep -o -E "^${K3D_CLUSTER_NAME}")" ] || \
   [ "$(kind get clusters | grep -o -E "^${KIND_CLUSTER_NAME}")" ]; then
  set +e
  namespaces=$(tk env list --json | jq -r '.[].spec.namespace' | sort | uniq)
  while IFS= read -r namespace; do
    echo "Creating namespace $namespace ....."
    out=$(kubectl create namespace $namespace 2>&1)
    if  [[ "$out" == *"AlreadyExists"* ]]; then
      echo "Namespace $namespace already exists, skipping"
    else
      echo "$out"
    fi
  done <<< "$namespaces"
  set -e
fi
