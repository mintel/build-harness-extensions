#!/bin/bash

K3D_CLUSTER_NAME=${K3D_CLUSTER_NAME:-"local"}

if k3d cluster list | grep -q -o -E "^${K3D_CLUSTER_NAME}"; then
  set +e
  namespaces="$(find rendered -type f -path '*/manifests/*.yaml' -print0 | xargs -0 -P1 yq eval-all --output-format csv '[.metadata.namespace] | map(select(. != null))' | tr ',' '\n' | sort -u)"
  while IFS= read -r namespace; do
    echo "Creating namespace $namespace ....."
    out=$(kubectl --context "k3d-${K3D_CLUSTER_NAME}" create namespace "$namespace" 2>&1)
    if  [[ "$out" == *"AlreadyExists"* ]]; then
      echo "Namespace $namespace already exists, skipping"
    else
      echo "$out"
    fi
  done <<< "$namespaces"
  set -e
fi
