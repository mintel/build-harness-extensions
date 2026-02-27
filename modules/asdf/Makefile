## mise helpers (replaces asdf)
MISE_VERSION := v2026.2.20
MISE_BIN := $(shell command -v mise 2>/dev/null || echo $(HOME)/.local/bin/mise)
MISE_REPO_DIR=$(shell pwd)
export PATH := $(HOME)/.local/share/mise/shims:$(PATH)

.PHONY: mise/install

## Installing mise and required tools
mise/install:
	@if ! command -v mise &>/dev/null; then \
		echo "Installing mise..."; \
		curl https://mise.run | MISE_VERSION=$(MISE_VERSION) sh; \
	fi
	@$(MISE_BIN) plugins install --yes 2>/dev/null || true; \
	grep -E "^#asdf:" '${MISE_REPO_DIR}/.tool-versions' | cut -d':' -f2- | sed 's/plugin add/plugins install/' | tr '\n' '\0' | xargs -0 -n1 -Icmd -- sh -c '$(MISE_BIN) cmd' || true; \
	$(MISE_BIN) install --yes
	@echo ""
	@echo "Add the following to your shell profile:"
	@echo '  eval "$$(~/.local/bin/mise activate zsh)"'
	@echo "Or for bash:"
	@echo '  eval "$$(~/.local/bin/mise activate bash)"'
	@echo ""
	@echo "See https://mise.jdx.dev/getting-started.html for details"

## Legacy alias for backwards compatibility
asdf/install: mise/install
