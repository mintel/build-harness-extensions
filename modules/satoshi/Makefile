S_RED := $(shell tput -Txterm setaf 1)
S_GRN := $(shell tput -Txterm setaf 2)
S_YLW := $(shell tput -Txterm setaf 3)
S_RST := $(shell tput -Txterm sgr0)
S_BLD := $(shell tput bold)

REQUIRED_SATOSHI_BINS := conftest helm jb kubectl kustomize opa pluto tk yq

.PHONY: satoshi/check-deps satoshi/check-asdf-dep

## Check dependencies for Satoshi
satoshi/check-deps: satoshi/check-asdf-dep
	$(foreach bin,$(REQUIRED_SATOSHI_BINS),\
		$(if $(shell command -v $(bin) 2> /dev/null),,$(error $(S_RED)[satoshi/check-deps] Please install `$(bin)` using `make asdf/install`$(S_RST))))

## Check dependencies (installer) for Satoshi
satoshi/check-asdf-dep:
	$(if $(shell command -v asdf 2> /dev/null),,$(error $(S_RED)[satoshi/check-asdf-dep] Please install `asdf` (https://github.com/asdf-vm/asdf)$(S_RST)))
