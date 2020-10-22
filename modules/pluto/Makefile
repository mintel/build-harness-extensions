## Pluto helpers
PLUTO_K8S_VERSION?=v1.16.0
PLUTO_VERBOSITY?=0
K8S_RENDERED_DIR?=./rendered/environments

pluto/validate:
	@errs=0;
	@for env in $(shell ls $(K8S_RENDERED_DIR)) ; do \
		if ! pluto detect-files -v $(PLUTO_VERBOSITY) --target-versions=k8s=$(PLUTO_K8S_VERSION) -o wide -d $(K8S_RENDERED_DIR)/$$env/manifests/; then \
			errs=$$(( $$errs + 1 )); \
		fi ;\
	done ;\
	if [ "$${errs:-0}" -gt 0 ]; then \
		exit 1; \
	fi
