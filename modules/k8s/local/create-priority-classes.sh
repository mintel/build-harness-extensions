#!/bin/bash

K3D_CLUSTER_NAME=${K3D_CLUSTER_NAME:-"local"}

if [ "$(k3d cluster list | grep -o -E "^${K3D_CLUSTER_NAME}")" ]; then
  set +e
  echo "Creating priority classes....."
    out=$(kubectl --context k3d-${K3D_CLUSTER_NAME} apply -f ${BUILD_HARNESS_EXTENSIONS_PATH}/modules/k8s/local/priority_class.yml 2>&1)
    echo "$out"
  set -e
fi
