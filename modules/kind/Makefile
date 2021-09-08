## KinD Helpers
export KIND_INSTALL_DOCKER_REGISTRY?=1

.PHONY: kind/create kind/delete

## Create KinD local cluster
kind/create:
	@@${BUILD_HARNESS_EXTENSIONS_PATH}/modules/kind//kind.sh create

## Delete a Kubernetes KinD local cluster
kind/delete:
	@@${BUILD_HARNESS_EXTENSIONS_PATH}/modules/kind/kind.sh delete
