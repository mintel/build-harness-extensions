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
	@echo "GitHub / jq diagnostics (hcl2json releases/latest) — before plugin/install GitHub traffic:"; \
	tmp=$$(mktemp); \
	code=$$(curl -s -o "$$tmp" -w "%{http_code}" https://api.github.com/repos/tmccombs/hcl2json/releases/latest); \
	echo "  HTTP status: $$code (403 often = unauthenticated rate limit; GITHUB_TOKEN raises limits)"; \
	if command -v jq >/dev/null 2>&1; then \
	  echo -n "  jq: "; jq --version; \
	  if jq -e . >/dev/null 2>&1 <"$$tmp"; then \
	    jq -r 'if .tag_name then "  jq parses JSON: tag_name=" + .tag_name elif .message then "  jq parses JSON: message=" + .message else "  jq parses JSON but no tag_name/message keys" end' "$$tmp"; \
	  else \
	    echo "  jq: response body is not JSON (e.g. HTML or empty)"; \
	  fi; \
	else \
	  echo "  jq: not in PATH — this Makefile does not call jq; install jq if a mise/asdf plugin errors on jq"; \
	fi; \
	rm -f "$$tmp"; \
	$(MISE_BIN) plugins install --verbose --yes 2>/dev/null || true; \
	grep -E "^#asdf:" '${MISE_REPO_DIR}/.tool-versions' | cut -d':' -f2- | sed 's/plugin add/plugins install/' | tr '\n' '\0' | xargs -0 -n1 -Icmd -- sh -c '$(MISE_BIN) --verbose cmd' || true; \
	$(MISE_BIN) install -q --yes
