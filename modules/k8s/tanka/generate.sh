#!/bin/bash

set -e -o pipefail

LC_COLLATE=C

PARAMS=""
while (( "$#" )); do
  case "$1" in
    -a|--app)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        TANKA_LABEL_APP=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -e|--env)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        TANKA_LABEL_ENV=$2
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
if [ -n "$TANKA_LABEL_APP" ]; then
	SELECTOR+=( "app in (${TANKA_LABEL_APP})" )
fi

if [ -n "$TANKA_LABEL_ENV" ]; then
	SELECTOR+=( "env in (${TANKA_LABEL_ENV})" )
fi

if [ "$TANKA_LABEL_ENV" != "local" ]; then
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

mkdir -p "$(pwd)/rendered/"
touch "$(pwd)/rendered/.gitkeep"

# Try to get a list of environments and print stdout and stderr if it fails
env_list=$(tk env list environments --names -l "$(join_arr , "${SELECTOR[@]}")" 2>&1) || (echo "$env_list"; exit 1)
# If no environments are returned. Exit here; we don't need to render anything.
if [[ $(tk env list environments --names -l "$(join_arr , "${SELECTOR[@]}")" | wc -l) -eq 0 ]]; then
  echo "No environments found. Exiting."
  exit 0
fi

# Export rendered manifests for each environment into a tmp dir
TMP_RENDERED="$(mktemp -d)"
TANKA_CACHE_DIR="${TANKA_REPO_DIR}/.tanka-cache"
mkdir -p "$TANKA_CACHE_DIR"
echo "Rendering manifests to $TMP_RENDERED..."

function finish {
  rm -rf "$TMP_RENDERED"
}
trap finish EXIT

base_selector="$(join_arr , "${SELECTOR[@]}")"

# Function to run tk export with given selector and target flags
# Args: $1=selector, $2=target_flag (optional), $3=description
run_tk_export() {
    local selector="$1"
    local target_flag="$2"
    local description="$3"

    local count
    count=$(tk env list environments --names -l "$selector" 2>/dev/null | wc -l)
    if [[ "$count" -gt 0 ]]; then
        echo "Exporting $count environment(s): $description"
        # shellcheck disable=SC2086
        tk export "$TMP_RENDERED/" "$TANKA_REPO_DIR/environments" -r \
            -l "$selector" \
            --format="$TANKA_EXPORT_FMT" \
            --merge-strategy=fail-on-conflicts \
            -c "$TANKA_CACHE_DIR" \
            -e '.*' \
            $target_flag
    fi
}

# Filter GrafanaDashboard manifests based on the 'grafana-dashboards' label:
#   - true/yes: Include all manifests (including dashboards)
#   - false/no: Exclude GrafanaDashboard manifests
#   - only: Include ONLY GrafanaDashboard manifests
#   - (missing): Default to excluding dashboards for backward compatibility

# Export environments with grafana-dashboards=true or grafana-dashboards=yes (include all manifests)
for val in "true" "yes"; do
    selector="${base_selector:+$base_selector,}grafana-dashboards=$val"
    run_tk_export "$selector" "" "grafana-dashboards=$val (all manifests)"
done

# Export environments with grafana-dashboards=only (dashboards only)
selector="${base_selector:+$base_selector,}grafana-dashboards=only"
run_tk_export "$selector" '-t GrafanaDashboard/.*' "grafana-dashboards=only"

# Export environments with grafana-dashboards=false or grafana-dashboards=no (exclude dashboards)
for val in "false" "no"; do
    selector="${base_selector:+$base_selector,}grafana-dashboards=$val"
    run_tk_export "$selector" '-t !GrafanaDashboard/.*' "grafana-dashboards=$val (excluding dashboards)"
done

# Export environments without grafana-dashboards label (default: exclude dashboards)
# Use !grafana-dashboards selector to match environments where the label does not exist
selector="${base_selector:+$base_selector,}!grafana-dashboards"
run_tk_export "$selector" '-t !GrafanaDashboard/.*' "without grafana-dashboards label (excluding dashboards)"

find "$TMP_RENDERED" -name "manifest.json" -delete

# Move the rendered manifests from the tmpdir to the rendered/ directory.
echo "Moving rendered manifests to rendered/ dir..."
swap_manifests() {
  # If no manifests were generated, delete the rendered directory
  if [[ ! -d "$TMP_RENDERED/$1/manifests" ]]; then
    echo "No manifests generated for $1 (deleting rendered directory)"
    rm -rf "$TANKA_REPO_DIR/rendered/$1"
    return
  fi

  # Create a skeleton of the manifests directory
  mkdir -p "$TANKA_REPO_DIR/rendered/$1"
  touch "$TANKA_REPO_DIR/rendered/$1/kustomization.yaml"
  # Remove the old manifests from the kustomization.yaml files
  yq eval --inplace 'del(.resources)' "$TANKA_REPO_DIR/rendered/$1/kustomization.yaml"
  # Swap old manifests for new
  rm -rf "$TANKA_REPO_DIR/rendered/$1/manifests"
  mv "$TMP_RENDERED/$1/manifests" "$TANKA_REPO_DIR/rendered/$1/manifests"
  # (Re-)populate the kustomization file
  pushd "$TANKA_REPO_DIR/rendered/$1" > /dev/null || exit 1
  kustomize edit add resource ./manifests/*.yaml
  popd > /dev/null || exit 1
}
for env_name in $(tk env list environments --names -l "$(join_arr , "${SELECTOR[@]}")" 2>/dev/null); do
  swap_manifests "$env_name" &
done
wait

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
