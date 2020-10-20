## Kubecfg helpers

## Validate manifests
kubecfg/validate:
	for env in $(shell ls ./rendered/environments) ; do \
		kubecfg validate ./rendered/environments/$$env/manifests/*.yaml ;\
	done 
