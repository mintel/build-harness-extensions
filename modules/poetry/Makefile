## poetry helpers
PY_POETRY = $(shell which poetry 2>/dev/null)
PY_VENV = $(shell $(PY_POETRY) env info --path 2>/dev/null)

POETRY_RUN ?= $(PY_POETRY) run
POETRY ?= $(PY_POETRY)

POETRY_HTTP_BASIC_USERNAME ?= ${JFROG_USERNAME}
POETRY_HTTP_BASIC_PASSWORD ?= ${JFROG_ACCESS_TOKEN}

ifneq ($(POETRY_OVERRIDE_PYTHON),)
	PYTHON := ${POETRY_RUN}
endif

## Test that poetry is in PATH.
poetry/py: python/check
	$(call assert-set,PY_POETRY)
	@echo "Found poetry: $(PY_POETRY)"

## Print build-harness vars about poetry.
poetry/debug: python/debug
	$(call print-var,PY_POETRY)
	$(call print-var,VIRTUAL_ENV)
	$(call print-var,POETRY)
	$(call print-var,PY_VENV)
	$(call print-var,POETRY_RUN)

## Validate the structure of pyproject.toml
poetry/check:
	$(call assert-set,POETRY)
	@$(POETRY) check

## Install dependencies
poetry/install: pyproject.toml
	$(call assert-set,POETRY)
	@$(POETRY) install

## Lock dependencies
poetry/lock:
	$(call assert-set,POETRY)
	@$(POETRY) lock

## Run poetry shell
poetry/shell:
	$(call assert-set,POETRY)
	@$(POETRY) shell

## HTTP Basic authenticate to source
poetry/auth/%:
	@$(POETRY) config http-basic.$* ${POETRY_HTTP_BASIC_USERNAME} ${POETRY_HTTP_BASIC_PASSWORD}
