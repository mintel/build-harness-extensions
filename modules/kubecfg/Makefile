## Kubecfg helpers

## Validate manifests
kubecfg/validate:
	@echo "kubecfg/validate"
	@echo "-------------------------------------------"
	@@for env in $(shell ls $(K8S_RENDERED_DIR)) ; do \
		echo "env: $$env" ;\
		kubecfg validate $(K8S_RENDERED_DIR)/$$env/manifests/*.yaml || exit 1;\
		echo "-------------------------------------------" ;\
	done 
