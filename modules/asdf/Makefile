## asdf helpers
ASDF_VERSION := 0.18.0
ASDF_BIN_DIR := ${HOME}/.local/bin
ASDF_REPO_DIR=$(shell pwd)

.PHONY: asdf/install

## Installing required tools
asdf/install:
	@CURRENT_VER=$$(asdf version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "0.0.0"); \
	if [ "$$CURRENT_VER" != "$(ASDF_VERSION)" ]; then \
		echo "Upgrading asdf from $$CURRENT_VER to $(ASDF_VERSION)..."; \
		rm -f $(ASDF_BIN_DIR)/asdf; \
		chmod -R u+w $${HOME}/.asdf 2>/dev/null; rm -rf $${HOME}/.asdf; \
		mkdir -p $(ASDF_BIN_DIR); \
		curl -fsSL "https://github.com/asdf-vm/asdf/releases/download/v$(ASDF_VERSION)/asdf-v$(ASDF_VERSION)-linux-amd64.tar.gz" \
			| tar -xz -C $(ASDF_BIN_DIR); \
		chmod +x $(ASDF_BIN_DIR)/asdf; \
		echo "Ensure $(ASDF_BIN_DIR) is in your PATH"; \
	else \
		echo "asdf $(ASDF_VERSION) already installed"; \
	fi
	@export PATH="$(ASDF_BIN_DIR):$$PATH"; \
	grep -E "^#asdf:" '${ASDF_REPO_DIR}/.tool-versions' | cut -d':' -f2- | tr '\n' '\0' | xargs -0 -n1 -Icmd -- sh -c 'asdf cmd' || true; \
	asdf install
	@echo "Ensure $(ASDF_BIN_DIR) and the asdf shims directory are on your PATH."
	@echo "Add the following to your shell profile:"
	@echo '  export PATH="$$HOME/.asdf/shims:$$HOME/.local/bin:$$PATH"'
	@echo "Or see https://asdf-vm.com/guide/getting-started.html for details"
