#!/bin/bash

set -e

LC_COLLATE=C

APP="$1"
ENV="$2"

TANKA_EXPORT_FMT="{{.apiVersion}}.{{.kind}}-{{ if.metadata.namespace}}{{.metadata.namespace }}-{{end}}{{.metadata.name }}"
TANKA_REPO_DIR=$(pwd)
ALL_ENVS=$(find environments -type f -name main.jsonnet -printf '%h\n' | grep "$APP" | grep "$ENV" | sort)

echo
echo "Generating rendered manifests in ./rendered"
echo "Run 'make jsonnet/[install|update]' beforehand if you require vendor package installation"
echo

mkdir -p "$(pwd)/rendered/"
touch "$(pwd)/rendered/.gitkeep"

# Generate the list of directories to render

if [[ -n "$APP" ]]; then
  dirs=$(echo "$ALL_ENVS" | grep "$APP")
  if [[ -n "$ENV" ]]; then
    dirs=$(echo "$dirs" | grep "$ENV")
  fi
else
  if [[ -n "$ENV" ]]; then
    dirs=$(echo "$ALL_ENVS" | grep "$ENV")
  else
    dirs="$ALL_ENVS"
  fi
fi

if [ "$ENV" != "local" ]; then
  dirs=$(echo "$dirs" | grep -v local)
fi
for env_path in $dirs; do
  cluster_envs=$(tk env list --names 2>/dev/null | grep "$env_path")
  for cluster_env in $cluster_envs; do
    echo "Generating $cluster_env"
    mkdir -p "./rendered/$cluster_env"
    touch "./rendered/$cluster_env/kustomization.yaml"
    yq -i eval 'del(.resources)' "./rendered/$cluster_env/kustomization.yaml"
    rm -f "./rendered/$cluster_env/manifests/"*.yaml
    rm -f "./rendered/$cluster_env/manifests/manifest.json"
    tk export "./rendered/$cluster_env/manifests" "$TANKA_REPO_DIR/$env_path" --format="$TANKA_EXPORT_FMT" --name="$cluster_env" > /dev/null
    pushd "./rendered/$cluster_env" > /dev/null || exit 1
    kustomize edit add resource ./manifests/*.yaml
    popd > /dev/null || exit 1
    echo
  done
done
