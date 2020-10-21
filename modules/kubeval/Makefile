## Kubeval helpers

KUBEVAL_K8S_VERSION?=1.16.4
KUBEVAL_ARGS?=--strict --quiet --output tap --ignore-missing-schemas

## Validate manifests
kubeval/validate:
	@echo "kubeval/validate"
	@echo "-------------------------------------------"
	@@for env in $(shell ls ./rendered/environments) ; do \
		echo "env: $$env" ;\
		kubeval $(KUBEVAL_ARGS) --kubernetes-version $(KUBEVAL_K8S_VERSION) ./rendered/environments/$$env/manifests/*.yaml || exit 1;\
		echo "-------------------------------------------" ;\
	done 
