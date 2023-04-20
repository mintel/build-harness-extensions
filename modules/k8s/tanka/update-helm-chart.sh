#!/usr/bin/env bash

CHART="$1"

for s in $(yq eval '.repositories[] | [.name, .url] | join(",")' chartfile.yaml); do
  repo_name="$(cut -d, -f1 <<< "$s")"
  repo_url="$(cut -d, -f2- <<< "$s")"
  helm repo add "$repo_name" "$repo_url" > /dev/null 2>&1
done

helm repo update > /dev/null 2>&1

latest_version="$(helm search repo "$CHART" --output yaml | yq eval ".[] | select(.name == \"$CHART\").version" -)"

yq eval -i "(.requires[] | select(.chart == \"$CHART\")).version = \"$latest_version\"" chartfile.yaml

tk tool charts vendor
