#!/usr/bin/env bash

# Given a path to a git checkout of core-cluster-jsonnet, this script will read the manifests for the GrafanaDataSource
# resources of the us-monitoring1 cluster, merge them, and patch them for use in a locally-running Grafana container.
# The result is output on stdout.

TMP_MONITORING_CLUSTER_JSONNET="$1"

# shellcheck disable=SC2016
yq eval-all '. as $manifest ireduce ([]; . + $manifest.spec.datasource) | {"apiVersion": 1, "datasources": .}' "$TMP_MONITORING_CLUSTER_JSONNET"/rendered/environments/grafana/aws.logs/manifests/grafana.integreatly.org-v1beta1.GrafanaDatasource-*.yaml |
yq eval '.datasources[] |= (
    .editable = true |
    .jsonData = .customJsonData | del(.customJsonData) |
    with(select(.type == "loki");
        .url = "https://gateway.loki.${MINTEL_BASE_URL}" |
        .basicAuth = true |
        .basicAuthUser = "${LOKI_GATEWAY_AUTH_USER}" |
        .secureJsonData.basicAuthPassword = "${LOKI_GATEWAY_AUTH_PASS}"
    ) |
    with(select(.type == "tempo");
        .url = "https://" + .secureJsonData.httpHeaderValue1 + ".tempo.${MINTEL_BASE_URL}" |
        .basicAuth = true |
        .basicAuthUser = "${TEMPO_" + (.secureJsonData.httpHeaderValue1 | upcase | sub("-", "_")) + "_USER}" |
        .secureJsonData.basicAuthPassword = "${TEMPO_" + (.secureJsonData.httpHeaderValue1 | upcase | sub("-", "_")) + "_PASS}"
    ) |
    with(select(.type == "prometheus");
        .url = "https://gateway.mimir.${MINTEL_BASE_URL}/prometheus" |
        .basicAuth = true |
        .basicAuthUser = "${MIMIR_GATEWAY_AUTH_USER}" |
        .secureJsonData.basicAuthPassword = "${MIMIR_GATEWAY_AUTH_PASS}"
    ) |
    with(select(.type == "grafana-athena-datasource");
        .
    ) |
    with(select(.type == "cloudwatch");
        .jsonData.defaultRegion = "us-east-2"
    ) |
    del(..|select(. == null))
)'
