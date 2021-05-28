## pipenv helpers
PY_PIPENV = $(shell which pipenv 2>/dev/null)
PY_VENV = $(shell $(PY_PIPENV) --venv 2> /dev/null)

PIPENV_RUN ?= $(PY_PIPENV) run
PIPENV ?= $(PY_PIPENV)

ifneq ($(USE_PIPENV),)
	PYTHON := ${PIPENV_RUN}
endif
