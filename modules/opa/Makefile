## OPA (open-policy-agent) helpers
OPA_POLICIES_DIR=/tmp/policies/opa/kustomize/policy

opa/check-env:
ifndef OPA_POLICY_REPO
	$(error OPA_POLICY_REPO is undefined)
endif

## Git clone policies (requires OPA_POLICIES_REPO argument)
opa/clone-policy: opa/check-env
	@if [ ! -d "$(OPA_POLICIES_DIR)" ]; then \
		git clone --depth=1 $(OPA_POLICY_REPO) $(OPA_POLICIES_DIR) ;\
	fi

## Validate manifests
opa/conftest: opa/clone-policy
	@for env in $(shell ls ./rendered/environments) ; do \
		conftest test ./rendered/environments/$$env/manifests/*.yaml -p $(OPA_POLICIES_DIR) ;\
	done 
