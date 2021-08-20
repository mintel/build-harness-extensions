#!/bin/bash

set -e

APP="$1"
ENV="$2"

TANKA_EXPORT_FMT="{{ env.metadata.name}}/{{ env.metadata.labels.env}}/manifests/{{.apiVersion}}.{{.kind}}-{{if.metadata.namespace}}{{.metadata.namespace}}-{{end}}{{.metadata.name}}"
TANKA_REPO_DIR=$(pwd)
TANKA_PARALLEL=8
TANkA_RENDERED_DIR="rendered-fast"

ALL_ENVS=$(find environments -type f -name main.jsonnet -printf '%h\n' | grep "$APP" | grep "$ENV" | sort)

echo
echo "Generating rendered manifests in ./${TANkA_RENDERED_DIR}"
echo "Run 'make jsonnet/[install|update]' beforehand if you require vendor package installation"
echo

mkdir -p "$(pwd)/${TANkA_RENDERED_DIR}/"
touch "$(pwd)/${TANkA_RENDERED_DIR}/.gitkeep"

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


echo "Removing old generated manifests (preserving image tagdata)..."
echo

for env_path in $dirs; do
  rendered_env_dir="${TANkA_RENDERED_DIR}/${env_path}"
  mkdir -p "${rendered_env_dir}"
  touch "${rendered_env_dir}/kustomization.yaml"
  rm -f "${rendered_env_dir}/manifests/"*.yaml
  rm -f "${rendered_env_dir}/manifests/manifest.json"
done

echo "Generating new manifests from tanka..."
echo

tk export \
   --selector="env in(aws.dev,aws.qa,aws.prod)" \
   --recursive \
   --parallel=${TANKA_PARALLEL} \
   --merge \
   ${TANkA_RENDERED_DIR}/environments \
  ./environments \
  --format="${TANKA_EXPORT_FMT}"
echo
echo "Updating kustomization with new manifests"
echo

for env_path in $dirs; do
  rendered_env_dir="${TANkA_RENDERED_DIR}/${env_path}"
  yq -i eval 'del(.resources)' "${rendered_env_dir}/kustomization.yaml"
  pushd "${rendered_env_dir}" > /dev/null || exit 1
  kustomize edit add resource ./manifests/*.yaml
  popd > /dev/null || exit 1
done

echo "Done!"
