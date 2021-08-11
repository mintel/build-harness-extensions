## OPA (open-policy-agent) helpers
OPA_POLICY_BRANCH?=main
OPA_POLICY_DIR=/tmp/opa-policy
OPA_POLICY_SUBDIR=opa/kubernetes
MANIFEST_DIRS:=$(shell find rendered/ -type d -name manifests)

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
opa/conftest: satoshi/check-deps opa/clone-policy
	@errs=0;
	@for dir in $(MANIFEST_DIRS) ; do \
		if ! conftest test --output stdout $$dir/*.yaml -p $(OPA_POLICY_DIR)/$(OPA_POLICY_SUBDIR); then \
			errs=$$(( $$errs + 1 )); \
		fi ;\
	done ;\
	if [ "$${errs:-0}" -gt 0 ]; then \
		exit 1; \
	fi
