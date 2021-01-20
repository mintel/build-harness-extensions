## Pluto helpers
PLUTO_K8S_VERSION?=v1.16.0
PLUTO_VERBOSITY?=0
K8S_RENDERED_DIR?=./rendered/environments

pluto/validate:
	pluto detect-files -v $(PLUTO_VERBOSITY) --target-versions=k8s=$(PLUTO_K8S_VERSION) -o wide -d $(K8S_RENDERED_DIR) ;\
