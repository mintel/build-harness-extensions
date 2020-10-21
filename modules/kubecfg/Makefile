## Kubecfg helpers

## Validate manifests
kubecfg/validate:
	@errs=0;
	@for env in $(shell ls $(K8S_RENDERED_DIR)) ; do \
		if ! kubecfg validate $(K8S_RENDERED_DIR)/$$env/manifests/*.yaml; then \
			errs=$$(( $$errs + 1 )); \
		fi ;\
	done ;\
	if [ "$${errs:-0}" -gt 0 ]; then \
		exit 1; \
	fi
