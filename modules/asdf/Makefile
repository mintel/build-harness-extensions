## asdf helpers
ASDF_ROOT := ${HOME}/.asdf
ASDF_REPO_DIR=$(shell pwd)

.PHONY: asdf/install

## Installing required tools
asdf/install:
	test -s $(ASDF_ROOT) || git clone https://github.com/asdf-vm/asdf.git $(ASDF_ROOT) && source $(ASDF_ROOT)/asdf.sh ;\
	grep -E "^#asdf:" '${ASDF_REPO_DIR}/.tool-versions' | cut -d':' -f2- | tr '\n' '\0' | xargs -0 -n1 -Icmd -- sh -c 'asdf cmd' || true;\
	asdf install
