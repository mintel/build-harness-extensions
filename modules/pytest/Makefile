## pytest helpers

# Run as python module so it supports virtual environment managers
PYTEST ?= $(PYTHON) -m pytest

## Run Python tests with pytest
pytest:
	$(PYTEST)

pytest/check:
	$(call assert-set,PYTEST)
	@echo "Found pytest: $(PYTEST)"

pytest/lf:
	$(PYTEST) --lf

pytest/pdb:
	$(PYTEST) --pdb

pytest/mf/%:
	$(PYTEST) --maxfail=$*

pytest/k/%:
	$(PYTEST) -k "$*"

pytest/m/%:
	$(PYTEST) -m "$*"

####
# Targets calling specific custom flags we commonly see used.
####

pytest/pre-build:
	@$(MAKE) pytest/m/"not postbuild"

pytest/post-build:
	@$(MAKE) pytest/m/"postbuild"
