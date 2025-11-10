## Mimirtool helpers
MANIFEST_DIRS:=$(shell find rendered/ -type d -name manifests 2>/dev/null)
TEMP_ALERTS_DIR := /tmp/mimirtool-alerts

.PHONY: mimirtool/check-env mimirtool/rules/lint mimirtool/clean

# Check mimirtool environment is suitable
mimirtool/check-env:
	@if [ ! -d ./rendered ]; then \
		echo "rendered manifests directory does not exist, run: make tanka/generate" ;\
		exit 1 ;\
	fi

# Clean temporary files
mimirtool/clean:
	@rm -rf $(TEMP_ALERTS_DIR)

## Validate PrometheusRule alerts
mimirtool/rules/lint: mimirtool/check-env mimirtool/clean
	@mkdir -p $(TEMP_ALERTS_DIR)
	@errs=0; \
	for dir in $(MANIFEST_DIRS); do \
		rulefiles=$$(find $${dir} -type f -name '*PrometheusRule*.yaml'); \
		if [ ! -z "$${rulefiles}" ]; then \
			echo "Validating PrometheusRules in $${dir}..."; \
			for rulefile in $${rulefiles}; do \
				filename=$$(basename $${rulefile}); \
				echo "  Checking $${filename}..."; \
				if ! yq eval '.spec' $${rulefile} > $(TEMP_ALERTS_DIR)/$${filename}.spec.yaml; then \
					echo "Failed to extract .spec from $${filename}"; \
	         				errs=$$(( $$errs + 1 )); \
	         				continue; \
	       	fi; \
	       	if ! mimirtool rules lint $(TEMP_ALERTS_DIR)/$${filename}.spec.yaml; then \
	         		echo "Validation failed for $${filename}"; \
			errs=$$(( $$errs + 1 )); \
	       	else \
	         		echo "Validation passed for $${filename}"; \
				fi; \
			done; \
	   		fi; \
	done; \
	if [ "$${errs:-0}" -gt 0 ]; then \
		echo "Validation failed with $${errs} error(s)"; \
		exit 1; \
	else \
		echo "All checks passed"
	fi
