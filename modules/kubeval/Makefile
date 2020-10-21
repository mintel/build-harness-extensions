## Kubeval helpers
KUBEVAL_K8S_VERSION?=1.16.4
KUBEVAL_ARGS?=--strict --quiet --output tap --ignore-missing-schemas
K8S_RENDERED_DIR?=./rendered/environments

## Validate manifests
kubeval/validate:
	kubeval $(KUBEVAL_ARGS) --kubernetes-version $(KUBEVAL_K8S_VERSION) -d $(K8S_RENDERED_DIR)
