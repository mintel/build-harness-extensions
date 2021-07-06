## python helpers
PY_PYTHON = $(shell which python 2>/dev/null)

PYTHON ?= $(PY_PYTHON)

## Check python path
python/check: $(PYTHON)
	$(call assert-set,PYTHON)
	@echo "Found python: $(PYTHON)"

## Debug python script
python/debug:
	$(call print-var,PY_PYTHON)
	$(call print-var,PYTHON)

## Clean all unecessary python project files
python/clean: python/clean/pyc python/clean/dist python/clean/docs python/clean/test

## Clean pyc files
python/clean/pyc:
	@/bin/echo -n "Cleaning pyc files .. "
	@find . -name '*.pyc' -exec rm -f {} +
	@find . -name '*.pyo' -exec rm -f {} +
	@find . -name '*~' -exec rm -f {} +
	@find . -name '__pycache__' -exec rm -fr {} +
	@echo "done"

## Clean dist files
python/clean/dist:
	@/bin/echo -n "Cleaning dist files .. "
	@rm -fr build/ dist/ .eggs/ requirements*.txt
	@find . -name '*.egg-info' -exec rm -fr {} +
	@find . -name '*.egg' -exec rm -fr {} +
	@echo "done"

## Clean docs build files
python/clean/docs:
	@/bin/echo -n "Cleaning docs build files .. "
	@rm -rf docs/_build/*
	@echo "done"

## Clean test files (coverage, reports, caches)
python/clean/test:
	@rm -fr htmlcov/ coverage.xml .coverage .coverage.* *.cover junit.xml junit-*.xml reports/ .pytest_cache/
