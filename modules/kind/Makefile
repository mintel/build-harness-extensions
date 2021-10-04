## KinD Helpers
export KIND_INSTALL_DOCKER_REGISTRY?=1

.PHONY: kind/create kind/delete

## DEPRECATED: Create KinD local cluster (use k3d instead)
kind/create:
	@@${BUILD_HARNESS_EXTENSIONS_PATH}/modules/kind//kind.sh create

## DEPRECATED: Delete a Kubernetes KinD local cluster (use k3d instead)
kind/delete:
	@@${BUILD_HARNESS_EXTENSIONS_PATH}/modules/kind/kind.sh delete
