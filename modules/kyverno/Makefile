## Kyverno policy checks against rendered cluster manifests.
KYVERNO_POLICY_BRANCH ?= main
KYVERNO_POLICY_DIR = /tmp/kyverno-policy
KYVERNO_POLICY_SUBDIR ?= rendered/environments/kyverno/aws.prod/manifests
KYVERNO_POLICY_REPO ?= git@gitlab.com:mintel/satoshi/kubernetes/jsonnet/sre/core-cluster-jsonnet.git
# CLI-only merges; never write under rendered/ (see kyverno/combine-policies).
KYVERNO_COMBINED_DIR ?= $(KYVERNO_POLICY_DIR)/.kyverno-combined
# Parallel kyverno apply workers (CEL ValidatingPolicy startup cost is high per process).
KYVERNO_APPLY_JOBS ?= 8
KYVERNO_APPLY_LOG_DIR ?= /tmp/kyverno-apply-logs
# Declarative `kyverno test` harness: fixtures in-repo, staged under /tmp for the CLI.
KYVERNO_UNIT_TEST_DIR ?= lib/kyverno/tests
KYVERNO_UNIT_SUITE ?= $(KYVERNO_UNIT_TEST_DIR)/exceptions
KYVERNO_UNIT_RENDERED ?= rendered/environments/kyverno/aws.dev/manifests
KYVERNO_UNIT_EXCEPTIONS_SRC ?= lib/kyverno/exceptions
KYVERNO_UNIT_STAGING ?= /tmp/kyverno-unit-test
MANIFEST_DIRS:=$(shell find rendered/ -type d -name manifests 2>/dev/null)

.PHONY: kyverno/check-env kyverno/print-cli-version kyverno/clone-policy kyverno/test kyverno/combine-policies kyverno/prepare-unit-test kyverno/test-unit

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

## Validate rendered workloads against kyverno policies (ClusterPolicy and/or ValidatingPolicy).
## Runs up to KYVERNO_APPLY_JOBS applies in parallel; captures each dir's --table output and
## replays logs in work-list order so CI output stays readable (no interleaved tables).
kyverno/test: satoshi/check-deps kyverno/print-cli-version kyverno/clone-policy kyverno/combine-policies
	@combined_dir="$(KYVERNO_COMBINED_DIR)" ;\
	log_dir="$(KYVERNO_APPLY_LOG_DIR)" ;\
	jobs="$(KYVERNO_APPLY_JOBS)" ;\
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
	rm -rf "$$log_dir" ;\
	mkdir -p "$$log_dir" ;\
	work_list=$$(mktemp) ;\
	for dir in $(MANIFEST_DIRS); do \
		matchedfiles=$$(find $${dir} -type f \( \
			-name 'apps-v1.Deployment*.yaml' -o \
			-name 'apps-v1.StatefulSet*' -o \
			-name 'apps-v1.DaemonSet*' -o \
			-name 'batch-v1.CronJob*' -o \
			-name 'batch-v1.Job*' \) 2>/dev/null) ;\
		if [ -n "$$matchedfiles" ]; then \
			printf '%s\n' "$$dir" >> "$$work_list" ;\
		fi ;\
	done ;\
	if [ ! -s "$$work_list" ]; then \
		rm -f "$$work_list" ;\
		echo "No workload manifests found under rendered/" ;\
		exit 0 ;\
	fi ;\
	printf '==> kyverno apply: %s dirs, %s parallel jobs\n' "$$(wc -l < "$$work_list")" "$$jobs" ;\
	export KYVERNO_POLICY_ARGS="$$policy_args" KYVERNO_EXC_ARG="$$exc_arg" KYVERNO_APPLY_LOG_DIR="$$log_dir" ;\
	xargs -P "$$jobs" -a "$$work_list" -I{} sh -c '\
		dir="$$1" ;\
		safe=$$(printf "%s" "$$dir" | sed "s|[ /]|_|g") ;\
		log="$$KYVERNO_APPLY_LOG_DIR/$$safe.log" ;\
		matchedfiles=$$(find "$$dir" -type f \( \
			-name "apps-v1.Deployment*.yaml" -o \
			-name "apps-v1.StatefulSet*" -o \
			-name "apps-v1.DaemonSet*" -o \
			-name "batch-v1.CronJob*" -o \
			-name "batch-v1.Job*" \) 2>/dev/null) ;\
		{ \
			echo "===== $$dir =====" ;\
			printf -- "--resource\0%s\0" $$matchedfiles \
				| xargs -0 kyverno apply --table $$KYVERNO_POLICY_ARGS $$KYVERNO_EXC_ARG ;\
		} >"$$log" 2>&1 ;\
		ec=$$? ;\
		echo $$ec > "$$KYVERNO_APPLY_LOG_DIR/$$safe.ec" ;\
		exit 0 \
	' _ {} ;\
	errs=0 ;\
	while IFS= read -r dir; do \
		safe=$$(printf "%s" "$$dir" | sed "s|[ /]|_|g") ;\
		log="$$log_dir/$$safe.log" ;\
		ec_file="$$log_dir/$$safe.ec" ;\
		ec=0 ;\
		[ -f "$$ec_file" ] && ec=$$(cat "$$ec_file") ;\
		cat "$$log" ;\
		if [ "$$ec" -ne 0 ]; then \
			errs=$$((errs + 1)) ;\
			echo "==> FAIL $$dir (exit $$ec)" ;\
		fi ;\
	done < "$$work_list" ;\
	rm -f "$$work_list" ;\
	if [ "$${errs:-0}" -gt 0 ]; then \
		echo "==> kyverno apply failed in $$errs directory(ies)" ;\
		exit 1 ;\
	fi

## Stage fixtures + sanitized policies under /tmp for `kyverno test` (nothing written under lib/).
kyverno/prepare-unit-test:
	@test -d "$(KYVERNO_UNIT_RENDERED)" || (echo "missing $(KYVERNO_UNIT_RENDERED); run: make k8s/tanka/generate/kyverno" && exit 1)
	@test -f "$(KYVERNO_UNIT_SUITE)/kyverno-test.yaml" || (echo "missing $(KYVERNO_UNIT_SUITE)/kyverno-test.yaml" && exit 1)
	@rm -rf "$(KYVERNO_UNIT_STAGING)"
	@mkdir -p "$(KYVERNO_UNIT_STAGING)/policies" "$(KYVERNO_UNIT_STAGING)/exceptions" "$(KYVERNO_UNIT_STAGING)/resources"
	@cp "$(KYVERNO_UNIT_SUITE)/kyverno-test.yaml" "$(KYVERNO_UNIT_STAGING)/kyverno-test.yaml"
	@cp "$(KYVERNO_UNIT_SUITE)/resources/"*.yaml "$(KYVERNO_UNIT_STAGING)/resources/"
	@# Source-of-truth exceptions (skip legacy TFC ClusterPolicy carve-out — not unit-tested).
	@for f in "$(KYVERNO_UNIT_EXCEPTIONS_SRC)"/*.yaml; do \
		case "$$(basename "$$f")" in ignore-tfc-workspace-deletes.yaml) continue ;; esac; \
		cp "$$f" "$(KYVERNO_UNIT_STAGING)/exceptions/"; \
	done
	@set -e; \
	found=0; \
	for f in "$(KYVERNO_UNIT_RENDERED)"/policies.kyverno.io-*ValidatingPolicy*.yaml; do \
		[ -f "$$f" ] || continue; \
		if yq -e '.metadata.labels["app.mintel.com/policy-set"] == "app-standards"' "$$f" >/dev/null 2>&1; then \
			continue; \
		fi; \
		found=1; \
		name=$$(yq -r '.metadata.name' "$$f"); \
		yq eval 'del(.metadata.namespace, .metadata.labels["app.mintel.com/region"])' "$$f" \
			> "$(KYVERNO_UNIT_STAGING)/policies/$${name}.yaml"; \
	done; \
	if [ "$$found" -eq 0 ]; then \
		echo "No ValidatingPolicies found in $(KYVERNO_UNIT_RENDERED)" >&2; \
		exit 1; \
	fi; \
	printf '==> staged %s (%s policies, %s exceptions)\n' \
		"$(KYVERNO_UNIT_STAGING)" \
		"$$(ls -1 "$(KYVERNO_UNIT_STAGING)/policies" | wc -l)" \
		"$$(ls -1 "$(KYVERNO_UNIT_STAGING)/exceptions" | wc -l)"

## Run declarative `kyverno test` from the /tmp staging dir.
kyverno/test-unit: satoshi/check-deps kyverno/print-cli-version kyverno/prepare-unit-test
	kyverno test "$(KYVERNO_UNIT_STAGING)"
