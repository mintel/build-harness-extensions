S_RED := $(shell tput -Txterm setaf 1)
S_GRN := $(shell tput -Txterm setaf 2)
S_YLW := $(shell tput -Txterm setaf 3)
S_RST := $(shell tput -Txterm sgr0)
S_BLD := $(shell tput bold)

REQUIRED_SATOSHI_BINS := conftest helm jb jsonnet kubectl kustomize opa pluto tk yq

export define SATOSHI_ASDF_TOOL_VERSIONS
conftest v0.27.0
helm 3.6.3
jb 0.4.0
jsonnet 0.17.0
kubectl 1.19.9
kustomize 4.2.0
opa 0.31.0
pluto 4.3.0
tanka 0.17.2
yq v4.12.0
endef

.PHONY: satoshi/check-deps satoshi/check-asdf-dep

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

## Update Satoshi asdf .tool-versions
satoshi/update-tools:
	@echo "$$SATOSHI_ASDF_TOOL_VERSIONS" > .tool-versions
	@make asdf/install
