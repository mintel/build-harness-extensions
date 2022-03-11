#!/bin/bash

set -e -o pipefail

LC_COLLATE=C

APP="$1"
ENV="$2"

SELECTOR=()
if [ -n "$APP" ]; then
	SELECTOR+=( "app=$APP" )
fi

if [ -n "$ENV" ]; then
	SELECTOR+=( "env=$ENV" )
fi

if [ "$ENV" != "local" ]; then
	SELECTOR+=( "env!=local" )
fi

TANKA_EXPORT_FMT="{{.apiVersion}}.{{.kind}}-{{ if.metadata.namespace}}{{.metadata.namespace }}-{{end}}{{.metadata.name }}"
TANKA_REPO_DIR=$(pwd)

join_arr() {
  local IFS="$1"
  shift
  echo "$*"
}

echo
echo "Generating rendered manifests in ./rendered"
echo "Run 'make jsonnet/[install|update]' beforehand if you require vendor package installation"
echo

mkdir -p "$(pwd)/rendered/"
touch "$(pwd)/rendered/.gitkeep"

# CPT-805: If tk env list fails, print stderr and exit but filter any TRACE messages; these will appear anyway during
# the tk export so we don't need them here and they produce quite a lot of spam. This means that we can send stderr to
# /dev/null below without losing any of the error messages we need when debugging.
err=$(tk env list environments --names -l "$(join_arr , "${SELECTOR[@]}")" 2>&1 | grep -v TRACE) && rc=$? || rc=$?
if [[ $rc != 0 ]]; then
	echo "$err"
	exit $rc
fi

for env_path in $(tk env list environments --names -l "$(join_arr , "${SELECTOR[@]}")" 2>/dev/null); do
	echo "Generating $env_path"
	mkdir -p "./rendered/$env_path"
	touch "./rendered/$env_path/kustomization.yaml"
	yq -i eval 'del(.resources)' "./rendered/$env_path/kustomization.yaml"
	rm -f "./rendered/$env_path/manifests/"*.yaml
	rm -f "./rendered/$env_path/manifests/manifest.json"
	tk export "./rendered/$env_path/manifests" "$TANKA_REPO_DIR/$env_path" --format="$TANKA_EXPORT_FMT" --name="$env_path" > /dev/null
	pushd "./rendered/$env_path" > /dev/null || exit 1
	kustomize edit add resource ./manifests/*.yaml
	popd > /dev/null || exit 1
	echo
done
