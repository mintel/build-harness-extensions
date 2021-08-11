## Pluto helpers
PLUTO_K8S_VERSION?=v1.16.0
PLUTO_VERBOSITY?=0
MANIFEST_DIRS:=$(shell find rendered/ -type d -name manifests)

.PHONY: pluto/validate

pluto/validate: satoshi/check-deps
	@errs=0;
	@for dir in $(MANIFEST_DIRS) ; do \
		if ! pluto detect-files -v $(PLUTO_VERBOSITY) --target-versions=k8s=$(PLUTO_K8S_VERSION) -o wide -d $$dir; then \
			errs=$$(( $$errs + 1 )); \
		fi ;\
	done ;\
	if [ "$${errs:-0}" -gt 0 ]; then \
		exit 1; \
	fi
