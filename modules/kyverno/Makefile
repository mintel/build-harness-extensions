## OPA (open-policy-agent) helpers
KYVERNO_POLICY_BRANCH ?= main
KYVERNO_POLICY_DIR = /tmp/kyverno-policy
KYVERNO_POLICY_SUBDIR ?= rendered/environments/kyverno/aws.prod/manifests
KYVERNO_POLICY_REPO ?= git@gitlab.com:mintel/satoshi/kubernetes/jsonnet/sre/core-cluster-jsonnet.git
MANIFEST_DIRS:=$(shell find rendered/ -type d -name manifests 2>/dev/null)

.PHONY: kyverno/check-env kyverno/clone-policy kyverno/test

# Check Kyverno environment is suitable
kyverno/check-env:
ifndef KYVERNO_POLICY_REPO
	$(error KYVERNO_POLICY_REPO is undefined)
endif

	@if [ ! -d ./rendered ]; then \
		echo "rendered manifests directory does not exist, run: make tanka/generate" ;\
		exit 1 ;\
	fi

## Git clone policies (requires KYVERNO_POLICY_REPO argument)
kyverno/clone-policy: kyverno/check-env
	@if [ -d "$(KYVERNO_POLICY_DIR)" ]; then \
		rm -rf $(KYVERNO_POLICY_DIR) ;\
	fi ;\
	git clone --depth=1 $(KYVERNO_POLICY_REPO) -b $(KYVERNO_POLICY_BRANCH) $(KYVERNO_POLICY_DIR) ;\

## Validate manifests
kyverno/test: satoshi/check-deps kyverno/clone-policy
	@errs=0;
	pushd $(KYVERNO_POLICY_DIR)/$(KYVERNO_POLICY_SUBDIR) ;\
	yq eval-all *.ClusterPolicy*.yaml > combined-cluster-policies.yaml ;\
	yq eval --inplace 'del(.metadata.namespace)' combined-cluster-policies.yaml ;\
	yq eval --inplace 'del(.metadata.labels["app.mintel.com/region"])' combined-cluster-policies.yaml ;\
	yq eval-all *.PolicyException*.yaml > combined-policy-exceptions.yaml ;\
	popd ;\
	for dir in $(MANIFEST_DIRS) ; do \
		matchedfiles=$$(find $${dir} -type f -name 'apps-v1.Deployment*.yaml' -o -name 'apps-v1.StatefulSet*' -o -name 'apps-v1.DaemonSet*' -o -name 'batch-v1.CronJob*' -o -name 'batch-v1.Job*') ;\
		if [ ! -z "$${matchedfiles}" ]; then \
			if ! printf -- '--resource\0%s\0' $$(find $${dir} -type f -name 'apps-v1.Deployment*.yaml' -o -name 'apps-v1.StatefulSet*' -o -name 'apps-v1.DaemonSet*' -o -name 'batch-v1.CronJob*' -o -name 'batch-v1.Job*') | xargs -0 kyverno apply --table $(KYVERNO_POLICY_DIR)/$(KYVERNO_POLICY_SUBDIR)/combined-cluster-policies.yaml --exceptions $(KYVERNO_POLICY_DIR)/$(KYVERNO_POLICY_SUBDIR)/combined-policy-exceptions.yaml; then \
				exit 1; \
				errs=$$(( $$errs + 1 )); \
			fi ;\
		fi; \
	done ;\
	if [ "$${errs:-0}" -gt 0 ]; then \
		exit 1; \
	fi
