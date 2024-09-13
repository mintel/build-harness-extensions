## OPA (open-policy-agent) helpers
OPA_POLICY_BRANCH?=main
OPA_POLICY_DIR=/tmp/opa-policy-$(OPA_POLICY_BRANCH)
OPA_POLICY_SUBDIR?=opa/kubernetes
MANIFEST_DIRS:=$(shell find rendered/ -type d -name manifests 2>/dev/null)
CONSTANTS_APPS_FILE := $(shell mktemp -p /tmp applications.XXXXX.yaml)

.PHONY: opa/check-env opa/clone-policy opa/conftest

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

## Fetch application constants and convert to a format rego can import (requires CONSTANTS_URL argument)
opa/fetch-constants:
ifndef CONSTANTS_URL
	$(error CONSTANTS_URL is undefined)
endif
	@curl --retry-all-errors -s -o $(CONSTANTS_APPS_FILE).curl $(CONSTANTS_URL)/applications.json && yq '{"applications": .}' $(CONSTANTS_APPS_FILE).curl > $(CONSTANTS_APPS_FILE)

## Validate manifests
opa/conftest: satoshi/check-deps opa/clone-policy opa/fetch-constants
	@errs=0;
	@for dir in $(MANIFEST_DIRS) ; do \
		if ! conftest test --output stdout $$dir/*.yaml \
		-d ${CONSTANTS_APPS_FILE} \
		-p $(OPA_POLICY_DIR)/opa/kubernetes/policy/utils.rego \
		-p $(OPA_POLICY_DIR)/$(OPA_POLICY_SUBDIR); then \
			errs=$$(( $$errs + 1 )); \
		fi ;\
	done ;\
	rm -f $(CONSTANTS_APPS_FILE) ;\
	rm -f $(CONSTANTS_APPS_FILE).curl ;\
	if [ "$${errs:-0}" -gt 0 ]; then \
		exit 1; \
	fi
