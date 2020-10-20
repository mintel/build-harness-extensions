## OPA (open-policy-agent) helpers
OPA_POLICY_DIR=/tmp/opa-policy
OPA_POLICY_BRANCH?=master

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
	@for env in $(shell ls ./rendered/environments) ; do \
		conftest test ./rendered/environments/$$env/manifests/*.yaml -p $(OPA_POLICY_DIR) ;\
	done
