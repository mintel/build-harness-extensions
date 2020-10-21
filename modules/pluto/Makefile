## Pluto helpers
PLUTO_K8S_VERSION?=v1.16.0
PLUTO_VERBOSITY?=0

## Validate manifests
pluto/validate:
	@echo "pluto/validate"
	@echo "-------------------------------------------"
	@@for env in $(shell ls ./rendered/environments) ; do \
		echo "env: $$env" ;\
		pluto detect-files -v $(PLUTO_VERBOSITY) --target-versions=k8s=$(PLUTO_K8S_VERSION) -o wide -d ./rendered/environments/$$env/manifests/ || exit 1;\
		echo "-------------------------------------------" ;\
	done 
