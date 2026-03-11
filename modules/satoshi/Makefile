S_RED := $(shell tput setaf 1 2> /dev/null || true)
S_GRN := $(shell tput setaf 2 2> /dev/null || true)
S_YLW := $(shell tput setaf 3 2> /dev/null || true)
S_RST := $(shell tput sgr0 2> /dev/null || true)
S_BLD := $(shell tput bold 2> /dev/null || true)

REQUIRED_SATOSHI_BINS := conftest helm jb jsonnet kubectl kustomize opa pluto tk yq mimirtool

.PHONY: satoshi/check-deps satoshi/check-mise-dep satoshi/update-makefile satoshi/update-tools

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

## Update Satoshi Makefile for k8s toolset
satoshi/update-makefile:
	@make satoshi/update-makefile/k8s

## Update Satoshi Makefile for a particular toolset e.g. k8s and tf
satoshi/update-makefile/%: FORCE
	$(shell curl -sSL -o Makefile "https://raw.githubusercontent.com/mintel/build-harness-extensions/main/modules/satoshi/${*}-makefile.template")

## Update Satoshi .tool-versions for k8s toolset
satoshi/update-tools:
	@make satoshi/update-tools/k8s

## Update Satoshi .tool-versions for a particular toolset e.g. k8s and tf
satoshi/update-tools/%: FORCE
	$(shell curl -sSL -o .tool-versions "https://raw.githubusercontent.com/mintel/build-harness-extensions/main/modules/satoshi/${*}-tool-versions")
	@make mise/install

## Update Satoshi asdf .tool-versions for k8s toolset and install with asdf
satoshi/tools/install: FORCE
	$(shell curl -sSL -o .tool-versions "https://raw.githubusercontent.com/mintel/build-harness-extensions/main/modules/satoshi/k8s-tool-versions")
	@make mise/install

FORCE:
