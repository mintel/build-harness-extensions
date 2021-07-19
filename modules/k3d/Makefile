## K3D Helpers
export K3D_INSTALL_DOCKER_REGISTRY?=true
export K3D_INSTALL_LB?=true

## Create Kubernetes k3d local cluster
k3d/create:
	@@${BUILD_HARNESS_EXTENSIONS_PATH}/modules/k3d/k3d.sh create

## Delete Kubernetes k3d local cluster
k3d/delete:
	@@${BUILD_HARNESS_EXTENSIONS_PATH}/modules/k3d/k3d.sh delete

