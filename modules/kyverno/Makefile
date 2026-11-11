## Kyverno policy checks against rendered cluster manifests.
KYVERNO_POLICY_BRANCH ?= main
KYVERNO_POLICY_DIR = /tmp/kyverno-policy
KYVERNO_POLICY_SUBDIR ?= rendered/environments/kyverno/aws.prod/manifests
KYVERNO_POLICY_REPO ?= git@gitlab.com:mintel/satoshi/kubernetes/jsonnet/sre/core-cluster-jsonnet.git
KYVERNO_CEL_TEST_DIR ?= lib/kyverno/tests/cel-cutover
KYVERNO_CEL_RENDERED ?= rendered/environments/kyverno/aws.dev/manifests
KYVERNO_CEL_PREPARED ?= $(KYVERNO_CEL_TEST_DIR)/prepared/policies
# CLI-only merges; never write under rendered/ (see kyverno/combine-policies).
KYVERNO_COMBINED_DIR ?= $(KYVERNO_POLICY_DIR)/.kyverno-combined
MANIFEST_DIRS:=$(shell find rendered/ -type d -name manifests 2>/dev/null)

.PHONY: kyverno/check-env kyverno/print-cli-version kyverno/clone-policy kyverno/test kyverno/test-cel kyverno/combine-policies kyverno/prepare-cel-test

## Print Kyverno CLI version and binary path (requires kyverno on PATH)
kyverno/print-cli-version:
	@if ! command -v kyverno >/dev/null 2>&1; then \
		echo "Kyverno CLI not found in PATH (install via mise: kyverno-cli)" >&2; \
		exit 1; \
	fi
	@ver=$$(kyverno version 2>/dev/null | sed -n 's/^Version: //p' | head -1); \
	printf '==> Kyverno CLI %s (%s)\n' "$${ver:-unknown}" "$$(command -v kyverno)"

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

## Merge ClusterPolicy / ValidatingPolicy / PolicyException YAML for kyverno apply.
## Strip namespace + region label so kyverno CLI accepts rendered manifests (same for
## ClusterPolicy and ValidatingPolicy; no core-cluster-jsonnet sanitize script).
## Skip app-standards ValidatingPolicies (OPA→Kyverno port; not ready for default CI).
kyverno/combine-policies:
	@manifest_dir="$(KYVERNO_POLICY_DIR)/$(KYVERNO_POLICY_SUBDIR)" ;\
	combined_dir="$(KYVERNO_COMBINED_DIR)" ;\
	set -e ;\
	mkdir -p "$$combined_dir" ;\
	rm -f "$$combined_dir"/combined-*.yaml "$$combined_dir"/.kyverno-cli-sanitized-*.yaml ;\
	cd "$$manifest_dir" ;\
	if compgen -G '*ClusterPolicy*.yaml' > /dev/null; then \
		yq eval-all 'del(.metadata.namespace, .metadata.labels["app.mintel.com/region"])' *ClusterPolicy*.yaml \
			> "$$combined_dir/combined-cluster-policies.yaml" ;\
	fi ;\
	if compgen -G 'policies.kyverno.io-*ValidatingPolicy*.yaml' > /dev/null; then \
		for f in policies.kyverno.io-*ValidatingPolicy*.yaml; do \
			if yq -e '.metadata.labels["app.mintel.com/policy-set"] == "app-standards"' "$$f" >/dev/null 2>&1; then \
				continue ;\
			fi ;\
			yq eval 'del(.metadata.namespace, .metadata.labels["app.mintel.com/region"])' "$$f" \
				> "$$combined_dir/.kyverno-cli-sanitized-$$(basename $$f)" ;\
		done ;\
		if compgen -G "$$combined_dir"/.kyverno-cli-sanitized-*.yaml > /dev/null; then \
			yq eval-all '.' "$$combined_dir"/.kyverno-cli-sanitized-*.yaml \
				> "$$combined_dir/combined-validating-policies.yaml" ;\
		fi ;\
		rm -f "$$combined_dir"/.kyverno-cli-sanitized-*.yaml ;\
	fi ;\
	if compgen -G '*PolicyException*.yaml' > /dev/null; then \
		yq eval-all '.' *PolicyException*.yaml \
			> "$$combined_dir/combined-policy-exceptions.yaml" ;\
	fi

## Validate rendered workloads against kyverno policies (ClusterPolicy and/or ValidatingPolicy)
kyverno/test: satoshi/check-deps kyverno/print-cli-version kyverno/clone-policy kyverno/combine-policies
	@errs=0; \
	combined_dir="$(KYVERNO_COMBINED_DIR)" ;\
	policy_args="" ;\
	if [ -f "$$combined_dir/combined-cluster-policies.yaml" ]; then \
		policy_args="$$policy_args $$combined_dir/combined-cluster-policies.yaml" ;\
	fi ;\
	if [ -f "$$combined_dir/combined-validating-policies.yaml" ]; then \
		policy_args="$$policy_args $$combined_dir/combined-validating-policies.yaml" ;\
	fi ;\
	if [ -z "$$policy_args" ]; then \
		echo "No combined ClusterPolicy or ValidatingPolicy manifests for $(KYVERNO_POLICY_SUBDIR)" ;\
		exit 1 ;\
	fi ;\
	exc_arg="" ;\
	if [ -f "$$combined_dir/combined-policy-exceptions.yaml" ]; then \
		exc_arg="--exceptions $$combined_dir/combined-policy-exceptions.yaml" ;\
	fi ;\
	for dir in $(MANIFEST_DIRS); do \
		matchedfiles=$$(find $${dir} -type f \( \
			-name 'apps-v1.Deployment*.yaml' -o \
			-name 'apps-v1.StatefulSet*' -o \
			-name 'apps-v1.DaemonSet*' -o \
			-name 'batch-v1.CronJob*' -o \
			-name 'batch-v1.Job*' \) 2>/dev/null) ;\
		if [ -n "$$matchedfiles" ]; then \
			if ! printf -- '--resource\0%s\0' $$matchedfiles \
				| xargs -0 kyverno apply --table $$policy_args $$exc_arg; then \
				errs=$$(( $$errs + 1 )); \
			fi ;\
		fi; \
	done ;\
	if [ "$${errs:-0}" -gt 0 ]; then \
		exit 1; \
	fi

## Copy aws.dev ValidatingPolicies into prepared/ (strip namespace/region for kyverno CLI)
kyverno/prepare-cel-test:
	@test -d $(KYVERNO_CEL_RENDERED) || (echo "rendered aws.dev kyverno missing; run: make k8s/tanka/generate/kyverno" && exit 1)
	@test -f $(KYVERNO_CEL_TEST_DIR)/policy-manifest.txt || (echo "missing $(KYVERNO_CEL_TEST_DIR)/policy-manifest.txt" && exit 1)
	@mkdir -p $(KYVERNO_CEL_PREPARED)
	@set -e; \
	while IFS= read -r name || [ -n "$$name" ]; do \
		case "$$name" in ''|\#*) continue ;; esac; \
		src="$(KYVERNO_CEL_RENDERED)/policies.kyverno.io-v1beta1.ValidatingPolicy-kyverno-$$name.yaml"; \
		test -f "$$src" || (echo "missing rendered policy $$src" && exit 1); \
		yq eval 'del(.metadata.namespace, .metadata.labels["app.mintel.com/region"])' "$$src" \
			> "$(KYVERNO_CEL_PREPARED)/$$name.yaml"; \
	done < "$(KYVERNO_CEL_TEST_DIR)/policy-manifest.txt"

## Regression tests for aws.dev CEL policies (upstream patches, autogen, exceptions)
kyverno/test-cel: satoshi/check-deps kyverno/print-cli-version kyverno/prepare-cel-test
	@test -f $(KYVERNO_CEL_TEST_DIR)/kyverno-test.yaml || (echo "missing $(KYVERNO_CEL_TEST_DIR)" && exit 1)
	kyverno test $(KYVERNO_CEL_TEST_DIR)

## Workload sweep against aws.dev CEL policies
kyverno/test-dev-workloads: KYVERNO_POLICY_SUBDIR=rendered/environments/kyverno/aws.dev/manifests
kyverno/test-dev-workloads: kyverno/test
