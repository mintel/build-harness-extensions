## Pluto helpers

PLUTO_K8S_TARGET_VERSION=v1.16

## Validate manifests
pluto/validate:
	@@for env in $(shell ls ./rendered/environments) ; do \
		pluto detect-files --target-versions=k8s=$(PLUTO_K8S_TARGET_VERSION) -o wide -d ./rendered/environments/$$env/manifests/ ;\
	done 
