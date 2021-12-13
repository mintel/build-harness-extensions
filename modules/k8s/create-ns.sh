#!/bin/bash

K3D_CLUSTER_NAME=${K3D_CLUSTER_NAME:-"local"}

if [ "$(k3d cluster list | grep -o -E "^${K3D_CLUSTER_NAME}")" ]; then
  set +e
  namespaces=$(tk env list --json | jq -r '.[].spec.namespace' | sort | uniq)
  while IFS= read -r namespace; do
    echo "Creating namespace $namespace ....."
    out=$(kubectl --context k3d-local create namespace $namespace 2>&1)
    if  [[ "$out" == *"AlreadyExists"* ]]; then
      echo "Namespace $namespace already exists, skipping"
    else
      echo "$out"
    fi
  done <<< "$namespaces"
  set -e
fi
