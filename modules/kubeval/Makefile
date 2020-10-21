## Kubeval helpers

KUBEVAL_K8S_VERSION?=1.16.4
KUBEVAL_ARGS?=--strict --quiet --output tap --ignore-missing-schemas
K8S_RENDERED_DIR?=./rendered/environments

## Validate manifests
kubeval/validate:
	@echo "kubeval/validate"
	@echo "-------------------------------------------"
	@@for env in $(shell ls $(K8S_RENDERED_DIR)) ; do \
		echo "env: $$env" ;\
		kubeval $(KUBEVAL_ARGS) --kubernetes-version $(KUBEVAL_K8S_VERSION) $(K8S_RENDERED_DIR)/$$env/manifests/*.yaml || exit 1;\
		echo "-------------------------------------------" ;\
	done 
