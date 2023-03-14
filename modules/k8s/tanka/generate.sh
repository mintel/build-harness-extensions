#!/bin/bash

set -e -o pipefail

LC_COLLATE=C

PARAMS=""
while (( "$#" )); do
  case "$1" in
    -a|--app)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        APP=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -e|--env)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        ENV=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -*)
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *)
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
eval set -- "$PARAMS"

SELECTOR=()
if [ -n "$APP" ]; then
	SELECTOR+=( "app in ($APP)" )
fi

if [ -n "$ENV" ]; then
	SELECTOR+=( "env in ($ENV)" )
fi

if [ "$ENV" != "local" ]; then
	SELECTOR+=( "env!=local" )
fi

# Tanka uses a Bell character as a placeholder in for a path separator.
# We can use a "replace" to hack it into the environment name.
# See: https://github.com/grafana/tanka/blob/v0.22.1/pkg/tanka/export.go#L23
TANKA_EXPORT_FMT='{{ env.metadata.name | replace "/" "\x07" }}/manifests/{{.apiVersion}}.{{.kind}}-{{ if.metadata.namespace }}{{ .metadata.namespace }}-{{end}}{{ if hasKey .metadata.annotations "app.mintel.com/altManifestFileSuffix" }}{{ get .metadata.annotations "app.mintel.com/altManifestFileSuffix" }}{{ else }}{{ .metadata.name }}{{ end }}'
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

# Delete the manifests for each environment as these will be re-generated
for env_name in $(tk env list environments --names -l "$(join_arr , "${SELECTOR[@]}")" 2>/dev/null); do
	mkdir -p "$TANKA_REPO_DIR/rendered/$env_name"
	touch "$TANKA_REPO_DIR/rendered/$env_name/kustomization.yaml"
	yq -i eval 'del(.resources)' "$TANKA_REPO_DIR/rendered/$env_name/kustomization.yaml"
	rm -f "$TANKA_REPO_DIR/rendered/$env_name/manifests/"*.yaml
done

# Export rendered manifests for each environment
tk export "$TANKA_REPO_DIR/rendered/" "$TANKA_REPO_DIR/environments" -r -l "$(join_arr , "${SELECTOR[@]}")" --format="$TANKA_EXPORT_FMT" --merge-strategy=fail-on-conflicts
find "$TANKA_REPO_DIR/rendered" -name "manifest.json" -delete

# Re-populate the kustomization file
for env_name in $(tk env list environments --names -l "$(join_arr , "${SELECTOR[@]}")" 2>/dev/null); do
	pushd "$TANKA_REPO_DIR/rendered/$env_name" > /dev/null || exit 1
	kustomize edit add resource ./manifests/*.yaml
	popd > /dev/null || exit 1
done

# Handle case where environment is deleted
#
# Find all the rendered environments (ignore local since we should not render this anyway)
rendered_envs=$(find rendered/environments -type d -not -path "*/local" | cut -d/ -f2,3,4 | sort | uniq  | grep -v "environments$")
# Get a list of known tanka environments
envs=$(tk env list --names)
# Check that the rendered environment is known - if not, delete it
for rendered_env in $rendered_envs; do
  if ! echo "$envs" | grep -q "$rendered_env"; then
    echo "Found rendered directory ${rendered_env} without an associated environment (deleting)"
    rm -rf "./rendered/${rendered_env}"
  fi
done
