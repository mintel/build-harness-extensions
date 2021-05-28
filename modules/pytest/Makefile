## pytest helpers
PYTEST ?= $(PYTHON) pytest

## Run Python tests with pytest
pytest:
	$(PYTEST)

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
