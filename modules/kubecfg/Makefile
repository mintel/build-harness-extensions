## Kubecfg helpers
MANIFEST_DIRS:=$(shell find rendered/ -type d -name manifests)

.PHONY: kubecfg/validate

## Validate manifests
kubecfg/validate:
	@errs=0;
	@for dir in $(MANIFEST_DIRS) ; do \
		if ! kubecfg validate $$dir/*.yaml; then \
			errs=$$(( $$errs + 1 )); \
		fi ;\
	done ;\
	if [ "$${errs:-0}" -gt 0 ]; then \
		exit 1; \
	fi
