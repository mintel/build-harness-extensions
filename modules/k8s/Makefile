## Generic kubernetes helpers

.PHONY: k8s/create-ns

## Create required namespaces in local cluster
k8s/create-ns:
	@@${BUILD_HARNESS_EXTENSIONS_PATH}/modules/k8s/create-ns.sh

## Creates an imagepull secret in repo namespaces based on used ~/.docker/config.json
k8s/create-imagepull-secret:
	@@${BUILD_HARNESS_EXTENSIONS_PATH}/modules/k8s/create-imagepull-secret.sh
