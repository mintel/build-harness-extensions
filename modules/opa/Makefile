## OPA (open-policy-agent) helpers
OPA_POLICY_DIR=/tmp/opa-policy
OPA_POLICY_BRANCH?=master
K8S_RENDERED_DIR?=./rendered/environments

# Check opa environment is suitable
opa/check-env:
ifndef OPA_POLICY_REPO
	$(error OPA_POLICY_REPO is undefined)
endif

	@if [ ! -d ./rendered ]; then \
		echo "rendered manifests directory does not exist, run: make tanka/generate" ;\
		exit 1 ;\
	fi

## Git clone policies (requires OPA_POLICY_REPO argument)
opa/clone-policy: opa/check-env
	@if [ -d "$(OPA_POLICY_DIR)" ]; then \
		rm -rf $(OPA_POLICY_DIR) ;\
	fi ;\
	git clone --depth=1 $(OPA_POLICY_REPO) -b $(OPA_POLICY_BRANCH) $(OPA_POLICY_DIR) ;\

## Validate manifests
opa/conftest: opa/clone-policy
	@errs=0;
	@for env in $(shell ls $(K8S_RENDERED_DIR)) ; do \
		if ! conftest test --output stdout $(K8S_RENDERED_DIR)/$$env/manifests/*.yaml -p $(OPA_POLICY_DIR); then \
			errs=$$(( $$errs + 1 )); \
		fi ;\
	done ;\
	if [ "$${errs:-0}" -gt 0 ]; then \
		exit 1; \
	fi
