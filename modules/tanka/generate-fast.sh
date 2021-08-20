#!/bin/bash

set -e

APP="$1"
ENV="$2"

TANKA_EXPORT_FMT="{{ env.metadata.name}}/{{ env.metadata.labels.env}}/manifests/{{.apiVersion}}.{{.kind}}-{{if.metadata.namespace}}{{.metadata.namespace}}-{{end}}{{.metadata.name}}"
TANKA_REPO_DIR=$(pwd)
TANKA_PARALLEL=16
TANkA_RENDERED_DIR="rendered-fast"

# TODO:  Handle case where env=all and app=all
ALL_ENVS=$(find environments -type f -name main.jsonnet -printf '%h\n' | grep "$APP" | grep "$ENV" | sort)

echo
echo "Generating rendered manifests in ./${TANkA_RENDERED_DIR}"
echo "Run 'make jsonnet/[install|update]' beforehand if you require vendor package installation"
echo

mkdir -p "$(pwd)/${TANkA_RENDERED_DIR}/"
touch "$(pwd)/${TANkA_RENDERED_DIR}/.gitkeep"

# Generate the list of directories to render

# TODO: Merge dirs/all-envs var
dirs=$(echo "$ALL_ENVS")

if [ "$ENV" != "local" ]; then
  dirs=$(echo "$dirs" | grep -v local)
fi

echo "Removing old generated manifests (preserving image tagdata)..."
echo

for env_path in $dirs; do
  rendered_env_dir="${TANkA_RENDERED_DIR}/${env_path}"
  kustomization="./${rendered_env_dir}/kustomization.yaml"
 
  mkdir -p "${rendered_env_dir}"
  if [ ! -f "${kustomization}" ] ; then
cat <<EOF > "${kustomization}"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
EOF
  fi

  rm -f "${rendered_env_dir}/manifests/"*.yaml
  rm -f "${rendered_env_dir}/manifests/manifest.json"
done

echo "Generating new manifests from tanka..."
echo

# TODO: Build selector
#   all envs (basename)
#   if app!="", add app 
   #--selector="env in(aws.dev,aws.qa,aws.prod)" \
# --selector="env in(aws.dev),name in(cpg-data-hub)" \

tk export \
   --recursive \
   --parallel=${TANKA_PARALLEL} \
   --selector="env notin(local)" \
   --merge \
   ${TANkA_RENDERED_DIR}/environments \
  ./environments \
  --format="${TANKA_EXPORT_FMT}"
echo
echo "Updating kustomization with new manifests"
echo

for env_path in $dirs; do
  rendered_env_dir="${TANkA_RENDERED_DIR}/${env_path}"
  kustomization="./${rendered_env_dir}/kustomization.yaml"
  yq -i eval 'del(.resources)' "${kustomization}"
  echo "resources:" >> "${kustomization}"
  ls -1 ${rendered_env_dir}/manifests/*.yaml | tr '\n' '\0' | xargs -0 -n 1 basename | xargs -I{} echo "- ./manifests/{}" >> "${kustomization}"
done

echo "Done!"
