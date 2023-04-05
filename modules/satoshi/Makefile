S_RED := $(shell tput setaf 1 2> /dev/null || true)
S_GRN := $(shell tput setaf 2 2> /dev/null || true)
S_YLW := $(shell tput setaf 3 2> /dev/null || true)
S_RST := $(shell tput sgr0 2> /dev/null || true)
S_BLD := $(shell tput bold 2> /dev/null || true)

REQUIRED_SATOSHI_BINS := conftest helm jb jsonnet kubectl kustomize opa pluto tk yq

.PHONY: satoshi/check-deps satoshi/check-asdf-dep satoshi/update-makefile satoshi/update-tools

# Skip checks if running in CI for now (binaries not installed by asdf)
ifndef CI
## Check dependencies for Satoshi
satoshi/check-deps: satoshi/check-asdf-dep
	$(foreach bin,$(REQUIRED_SATOSHI_BINS),\
		$(if $(shell command -v $(bin) 2> /dev/null),,$(error $(S_RED)[satoshi/check-deps] Please install `$(bin)` using `make asdf/install`$(S_RST))))

## Check dependencies (installer) for Satoshi
satoshi/check-asdf-dep:
	$(if $(shell command -v asdf 2> /dev/null),,$(error $(S_RED)[satoshi/check-asdf-dep] Please install `asdf` (https://github.com/asdf-vm/asdf)$(S_RST)))
endif

## Update Satoshi Makefile for k8s toolset
satoshi/update-makefile:
	@make satoshi/update-makefile/k8s

## Update Satoshi Makefile for a particular toolset e.g. k8s and tf
satoshi/update-makefile/%:
	$(shell curl -sSL -o Makefile "https://raw.githubusercontent.com/mintel/build-harness-extensions/main/modules/satoshi/${*}-makefile.template")

## Update Satoshi asdf .tool-versions for k8s toolset
satoshi/update-tools:
	@make satoshi/update-tools/k8s

## Update Satoshi asdf .tool-versions for a particular toolset e.g. k8s and tf
satoshi/update-tools/%:
	$(shell curl -sSL -o .tool-versions "https://raw.githubusercontent.com/mintel/build-harness-extensions/main/modules/satoshi/${*}-tool-versions")
	@make asdf/install
