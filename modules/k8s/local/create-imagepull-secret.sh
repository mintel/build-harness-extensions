#!/bin/bash

K3D_CLUSTER_NAME=${K3D_CLUSTER_NAME:-"local"}

if [ "$(k3d cluster list | grep -o -E "^${K3D_CLUSTER_NAME}")" ]; then
  set +e
  namespaces=$(tk env list --json | jq -r '.[].spec.namespace' | sort | uniq)
  while IFS= read -r namespace; do
    echo "Creating imagepull secret in $namespace namespace....."
    out=$(kubectl --context k3d-${K3D_CLUSTER_NAME} create secret generic image-pull-gitlab -n $namespace --from-file=.dockerconfigjson=$HOME/.docker/config.json --type=kubernetes.io/dockerconfigjson 2>&1)
    if  [[ "$out" == *"AlreadyExists"* ]]; then
      echo "Secret already exists in $namespace namespace, skipping"
    else
      echo "$out"
    fi
  done <<< "$namespaces"
  set -e
fi
