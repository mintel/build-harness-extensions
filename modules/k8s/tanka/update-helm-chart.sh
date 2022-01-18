#!/bin/bash

CHART_NAME="$1"

helm repo list | grep -i mintel > /dev/null 2>&1
if [ $? -ne 0 ]; then
  helm repo add mintel https://mintel.github.io/helm-charts > /dev/null 2>&1
fi

helm repo update > /dev/null 2>&1

result=$(helm search repo ${CHART_NAME})

latest_version=`echo $result | sed "s|.*${CHART_NAME} \([0-9\.]*\) .*|\1|"`

yq -i eval "del(.requires.[] | select(.chart == \"${CHART_NAME}\"))" chartfile.yaml

tk tool charts add $1@$latest_version
