#!/bin/bash

set -e
shopt -s extglob; # Need extented glob patterns to exclude local env by default.

APP="$1"
if [[ -z "$APP" ]]; then
  APP="*"
fi

ENV="$2"
if [[ -z "$ENV" ]]; then
  # Don't render the local env unless explicitly specified.
  ENV="!(local)"
fi

TANKA_DEFAULT_EXPORT_FMT="{{.apiVersion}}.{{.kind}}-{{ if.metadata.namespace}}{{.metadata.namespace }}-{{end}}{{.metadata.name }}"
TANKA_EXPORT_FMT=${TANKA_EXPORT_FMT:-$TANKA_DEFAULT_EXPORT_FMT}

echo
echo "Generating rendered manifests in ./rendered"
echo "Run 'make jsonnet/[install|update]' beforehand if you require vendor package installation"
echo

mkdir -p "rendered"
touch "rendered/.gitkeep"

# Generate the list of directories to render

for main_file in environments/$APP/$ENV/main.jsonnet; do
  env_dir="$(dirname "$main_file")"
  rendered_dir="rendered/$env_dir"
  echo "Generating $rendered_dir"
  mkdir -p "$rendered_dir"
  touch "$rendered_dir/kustomization.yaml"
  yq -i eval 'del(.resources)' "$rendered_dir/kustomization.yaml"
  rm -rf "$rendered_dir/manifests"
  tk export --format="$TANKA_EXPORT_FMT" "$env_dir" "$rendered_dir/manifests" > /dev/null
  (cd "$rendered_dir" && kustomize edit add resource ./manifests/*.yaml)
done
