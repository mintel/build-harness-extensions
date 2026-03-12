S_RED := $(shell tput setaf 1 2> /dev/null || true)
S_GRN := $(shell tput setaf 2 2> /dev/null || true)
S_YLW := $(shell tput setaf 3 2> /dev/null || true)
S_RST := $(shell tput sgr0 2> /dev/null || true)
S_BLD := $(shell tput bold 2> /dev/null || true)

REQUIRED_SATOSHI_BINS := conftest helm jb jsonnet kubectl kustomize opa pluto tk yq mimirtool

.PHONY: satoshi/check-deps satoshi/check-mise-dep \
       satoshi/update-makefile satoshi/update-tools

# Skip checks if running in CI for now (binaries not installed by mise)
ifndef CI
## Check dependencies for Satoshi
satoshi/check-deps: satoshi/check-mise-dep
	@for bin in $(REQUIRED_SATOSHI_BINS); do \
		if ! command -v $$bin &> /dev/null; then \
			echo "$(S_RED)[satoshi/check-deps] Please install \`$$bin\` using \`make mise/install\`$(S_RST)" >&2; \
			exit 1; \
		fi; \
	done

## Check dependencies (installer) for Satoshi
satoshi/check-mise-dep:
	@if ! command -v mise &> /dev/null; then \
		echo "$(S_RED)[satoshi/check-mise-dep] Please install \`mise\` (https://mise.jdx.dev)$(S_RST)" >&2; \
		exit 1; \
	fi
endif

## Update Satoshi Makefile for a particular toolset e.g. k8s and tf
satoshi/makefile/update/%: FORCE
	$(shell curl -sSL -o Makefile "https://raw.githubusercontent.com/mintel/build-harness-extensions/main/modules/satoshi/${*}-makefile.template")

## Update Satoshi .tool-versions for a particular toolset e.g. k8s and tf
satoshi/tools/update/%: FORCE
	$(shell curl -sSL -o .tool-versions "https://raw.githubusercontent.com/mintel/build-harness-extensions/main/modules/satoshi/${*}-tool-versions")

## Update Satoshi mise.tool-versions for k8s toolset and install with mise
satoshi/tools/install: FORCE
	@$(MAKE) mise/install

## DEPRECATED: Use satoshi/makefile/update/k8s instead
satoshi/update-makefile:
	@echo "$(S_YLW)$(S_BLD)[DEPRECATED] satoshi/update-makefile is deprecated, use satoshi/makefile/update/k8s instead$(S_RST)" >&2
	@$(MAKE) satoshi/makefile/update/k8s

## DEPRECATED: Use satoshi/makefile/update/<toolset> instead
satoshi/update-makefile/%: FORCE
	@echo "$(S_YLW)$(S_BLD)[DEPRECATED] satoshi/update-makefile/$* is deprecated, use satoshi/makefile/update/$* instead$(S_RST)" >&2
	@$(MAKE) satoshi/makefile/update/$*

## DEPRECATED: Use satoshi/tools/update/k8s instead
satoshi/update-tools:
	@echo "$(S_YLW)$(S_BLD)[DEPRECATED] satoshi/update-tools is deprecated, use satoshi/tools/update/k8s instead$(S_RST)" >&2
	@$(MAKE) satoshi/tools/update/k8s

## DEPRECATED: Use satoshi/tools/update/<toolset> instead
satoshi/update-tools/%: FORCE
	@echo "$(S_YLW)$(S_BLD)[DEPRECATED] satoshi/update-tools/$* is deprecated, use satoshi/tools/update/$* instead$(S_RST)" >&2
	@$(MAKE) satoshi/tools/update/$*

FORCE:
