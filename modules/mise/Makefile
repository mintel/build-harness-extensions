## mise helpers (replaces asdf)
MISE_VERSION := v2026.2.20
MISE_BIN := $(shell command -v mise 2>/dev/null || echo $(HOME)/.local/bin/mise)
MISE_REPO_DIR=$(shell pwd)
ifndef CI
$(if $(filter mise/install,$(MAKECMDGOALS)),,$(if $(shell command -v mise 2>/dev/null),,$(warning mise is not installed. See https://mise.jdx.dev)))
$(if $(filter mise/install,$(MAKECMDGOALS)),,$(if $(MISE_SHELL),,$(warning mise activate is not configured in your shell. Add to your shell profile: eval "$$(mise activate zsh)" or eval "$$(mise activate bash)")))
endif
export PATH := $(shell $(MISE_BIN) env --shell bash 2>/dev/null | grep '^export PATH' | cut -d= -f2- | tr -d "'"):$(PATH)

.PHONY: mise/install

## Installing mise and required tools
mise/install:
	@if ! command -v mise &>/dev/null; then \
		echo "Installing mise..."; \
		curl https://mise.run | MISE_VERSION=$(MISE_VERSION) sh; \
	fi
	@$(MISE_BIN) plugins install --verbose --yes 2>/dev/null || true; \
	grep -E "^#asdf:" '${MISE_REPO_DIR}/.tool-versions' | cut -d':' -f2- | sed 's/plugin add/plugins install/' | tr '\n' '\0' | xargs -0 -n1 -Icmd -- sh -c '$(MISE_BIN) --verbose cmd' || true; \
	$(MISE_BIN) install -q --yes
