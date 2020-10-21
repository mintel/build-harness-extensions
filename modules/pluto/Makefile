## Pluto helpers
PLUTO_K8S_VERSION?=v1.16.0
PLUTO_VERBOSITY?=0
K8S_RENDERED_DIR?=./rendered/environments

## Validate manifests
pluto/validate:
	@echo "pluto/validate"
	@echo "-------------------------------------------"
	@@for env in $(shell ls $(K8S_RENDERED_DIR)) ; do \
		echo "env: $$env" ;\
		pluto detect-files -v $(PLUTO_VERBOSITY) --target-versions=k8s=$(PLUTO_K8S_VERSION) -o wide -d $(K8S_RENDERED_DIR)/$$env/manifests/ || exit 1;\
		echo "-------------------------------------------" ;\
	done 
