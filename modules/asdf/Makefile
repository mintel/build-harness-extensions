## asdf helpers
ASDF_ROOT := ${HOME}/.asdf
ASDF_REPO_DIR=$(shell pwd)

.PHONY: asdf/install

## Installing required tools
asdf/install:
	test -s $(ASDF_ROOT) || git clone https://github.com/asdf-vm/asdf.git $(ASDF_ROOT) && source $(ASDF_ROOT)/asdf.sh ;\
	cat ${ASDF_REPO_DIR}/.tool-versions | grep -v "#" | cut -d' ' -f1 | xargs -I_pkg -- sh -c 'asdf plugin add _pkg ; asdf install _pkg'
