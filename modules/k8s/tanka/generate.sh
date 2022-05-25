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

TANKA_EXPORT_FMT='{{.apiVersion}}.{{.kind}}-{{ if.metadata.namespace}}{{.metadata.namespace }}-{{end}}{{ if index .metadata.annotations "app.mintel.com/altName" }}{{ index .metadata.annotations "app.mintel.com/altName" }}{{ else }}{{.metadata.name }}{{ end }}'
TANKA_REPO_DIR=$(pwd)

join_arr() {
  local IFS="$1"
  shift
  echo "$*"
}

find_jsonnet() {
	local env_path; env_path=$1
	if ! find "$env_path" -name '*.jsonnet' >/dev/null 2>&1; then
		env_path=$(dirname "$env_path")
		find_jsonnet "$env_path"
	else
		echo "$env_path"
	fi
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

for env_name in $(tk env list environments --names -l "$(join_arr , "${SELECTOR[@]}")" 2>/dev/null); do
	echo "Generating $env_name"
	mkdir -p "./rendered/$env_name"
	touch "./rendered/$env_name/kustomization.yaml"
	yq -i eval 'del(.resources)' "./rendered/$env_name/kustomization.yaml"
	rm -f "./rendered/$env_name/manifests/"*.yaml
	rm -f "./rendered/$env_name/manifests/manifest.json"
	env_path=$(find_jsonnet "$TANKA_REPO_DIR/$env_name")
	tk export "./rendered/$env_name/manifests" "$env_path" --format="$TANKA_EXPORT_FMT" --name="$env_name" > /dev/null
	pushd "./rendered/$env_name" > /dev/null || exit 1
	kustomize edit add resource ./manifests/*.yaml
	popd > /dev/null || exit 1
	echo
done
