#!/bin/bash

set -e

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
  echo "Generating $env_path"
  mkdir -p ./rendered/$env_path
  touch ./rendered/$env_path/kustomization.yaml
  yq -i eval 'del(.resources)' ./rendered/$env_path/kustomization.yaml
  rm -f ./rendered/$env_path/manifests/*.yaml
  rm -f ./rendered/$env_path/manifests/manifest.json
  tk export "./rendered/$env_path/manifests" "$TANKA_REPO_DIR/$env_path" --format="$TANKA_EXPORT_FMT" > /dev/null
  pushd "./rendered/$env_path" > /dev/null || exit 1
  kustomize edit add resource ./manifests/*.yaml
  popd > /dev/null || exit 1
done
