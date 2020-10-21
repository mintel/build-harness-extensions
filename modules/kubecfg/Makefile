## Kubecfg helpers

## Validate manifests
kubecfg/validate:
	@echo "kubecfg/validate"
	@echo "-------------------------------------------"
	@@for env in $(shell ls ./rendered/environments) ; do \
		echo "env: $$env" ;\
		kubecfg validate ./rendered/environments/$$env/manifests/*.yaml || exit 1;\
		echo "-------------------------------------------" ;\
	done 
