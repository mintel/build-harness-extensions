## alembic helpers

# Run as python module so it supports virtual environment managers
ALEMBIC ?= $(PYTHON) -m alembic

## Display the current revision
alembic/current:
	$(call assert-set,ALEMBIC)
	@$(ALEMBIC) current

## List changeset scripts in chronological order
alembic/history:
	$(call assert-set,ALEMBIC)
	@$(ALEMBIC) history

## Apply migrations to the latest revision
alembic/upgrade:
	$(call assert-set,ALEMBIC)
	@$(ALEMBIC) upgrade head
