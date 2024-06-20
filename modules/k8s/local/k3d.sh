#!/usr/bin/env bash
#
# Helper script to start k3d
#
# Also adds a docker-registry and an ingress to aid local development
#
# See https://k3d.io/
#
set -o errexit

[ "$TRACE" ] && set -x

K3D_PREFIX="k3d"
K3D_K8S_IMAGE=${K3D_K8S_IMAGE:-"rancher/k3s:v1.27.14-k3s1"}
K3D_CLUSTER_NAME=${K3D_CLUSTER_NAME:-"local"}
K3D_DOCKER_REGISTRY_NAME=${K3D_DOCKER_REGISTRY_NAME:-"default.localhost"}
K3D_DOCKER_REGISTRY_PORT=${K3D_DOCKER_REGISTRY_PORT:-"5000"}
K3D_INSTALL_DOCKER_REGISTRY=${K3D_INSTALL_DOCKER_REGISTRY:-"true"}
K3D_DELETE_DOCKER_REGISTRY=${K3D_DELETE_DOCKER_REGISTRY:-"false"}
K3D_INSTALL_LB=${K3D_INSTALL_LB:-"true"}
K3D_WAIT=${K3D_WAIT:-"120s"}
K3D_API_SERVER_ADDRESS=${K3D_API_SERVER_ADDRESS:-"0.0.0.0"}
K3D_API_SERVER_PORT=${K3D_API_SERVER_PORT:-6443}
K3D_NETWORK=${K3D_NETWORK:-"mintelnet"}
K3D_NODES=${K3D_NODES:-1}


## Create a cluster with the local registry enabled in container
create() {
  if [ "$(k3d cluster list | grep -o -E "^${K3D_CLUSTER_NAME}")" ]; then
    echo "K3d cluster ${K3D_CLUSTER_NAME} already exists - you may want to cleanup with: make k3d/delete"
    exit 0
  fi

  if [ "${K3D_INSTALL_DOCKER_REGISTRY}" = 'true' ] && [ ! "$(k3d registry list | grep -o -E "^${K3D_PREFIX}-${K3D_DOCKER_REGISTRY_NAME}")" ]; then
    k3d registry create "${K3D_DOCKER_REGISTRY_NAME}" --port "${K3D_DOCKER_REGISTRY_PORT}"
  fi

  local cluster_create_args=(
    --image="${K3D_K8S_IMAGE}"
    --api-port="${K3D_API_SERVER_ADDRESS}:${K3D_API_SERVER_PORT}"
    --timeout="${K3D_WAIT}"
    --port "80:80@loadbalancer"
    --port "443:443@loadbalancer"
    --servers ${K3D_NODES}
  )

  if [ "${K3D_INSTALL_DOCKER_REGISTRY}" = 'true' ]; then
    cluster_create_args+=("--registry-use" "${K3D_PREFIX}-${K3D_DOCKER_REGISTRY_NAME}:${K3D_DOCKER_REGISTRY_PORT}")
	fi

  # Skip configuring docker-network if we're running in CI (we don't have accesss to docker).
  if [ -z "${CI}" ]; then
    if [ -n "${K3D_NETWORK}" ] ; then
      if [ $(docker network ls --format {{.Name}} | grep -w "${K3D_NETWORK}") ]; then
        cluster_create_args+=("--network" "${K3D_NETWORK}")
      else
        echo "Specified docker network ${K3D_NETWORK} does not exist. Skipping!"
      fi
    fi
  fi

  cluster_create_args+=("--k3s-arg" "--disable-network-policy@server:*")

  k3d cluster create "${K3D_CLUSTER_NAME}" "${cluster_create_args[@]}"

  # Wait for core-components to be available
  kubectl rollout status deploy/coredns -n kube-system -w
  kubectl rollout status deploy/metrics-server -n kube-system -w
  kubectl rollout status deploy/local-path-provisioner -n kube-system -w

  if [ -z "${CI}" ]; then
    # Not required in CI
    helm repo add stakater https://stakater.github.io/stakater-charts
    helm install stakater stakater/reloader --namespace default
  fi
  make k8s/local/create-ns

  if [ -z "${CI}" ]; then
    # Not required in CI and does not have a local docker config.json to mount
    make k8s/local/create-imagepull-secret
  fi
}

## Delete the cluster
delete() {
  k3d cluster delete "${K3D_CLUSTER_NAME}"

  if [ "${K3D_DELETE_DOCKER_REGISTRY}" = 'true' ]; then
    k3d registry rm "k3d-${K3D_DOCKER_REGISTRY_NAME}"
  fi
}

## Start the cluster
up() {
  set +e
  curl -I -k --insecure "https://$K3D_API_SERVER_ADDRESS:$K3D_API_SERVER_PORT/livez" 2>&1 | grep -i 'unauthorized' > /dev/null
  if [ $? -eq 0 ]; then
    echo "${K3D_CLUSTER_NAME} cluster already running."
  else
    k3d cluster start "${K3D_CLUSTER_NAME}"
  fi
  set -e
}

## Stop the cluster
down() {
  k3d cluster stop "${K3D_CLUSTER_NAME}"
}

## Display usage
usage()
{
  echo "usage: $0 [create|delete]"
}

## Argument parsing
if [ "$#" = "0" ]; then
  usage
  exit 1
fi

while [ "$1" != "" ]; do
    case $1 in
        create )                create
                                ;;
        up )                    up
                                ;;
        down )                  down
                                ;;
        delete )                delete
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done
