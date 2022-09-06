## pipenv helpers
PY_PIPENV = $(shell which pipenv 2>/dev/null)
PY_VENV = $(shell $(PY_PIPENV) --venv 2> /dev/null)

PIPENV_RUN ?= $(PY_PIPENV) run
PIPENV ?= $(PY_PIPENV)

ifneq ($(PIPENV_OVERRIDE_PYTHON),)
	PYTHON := ${PIPENV_RUN} python
endif

## Test that pipenv is in PATH.
pipenv/py: python/check
	$(call assert-set,PY_PIPENV)
	@echo "Found pipenv: $(PY_PIPENV)"

## Lock dependencies
pipenv/lock:
	$(call assert-set,$(shell $(PIPENV) --where 2> /dev/null))
	@$(PIPENV) lock
