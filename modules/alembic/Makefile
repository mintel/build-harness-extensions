## alembic helpers
PY_ALEMBIC = $(shell which alembic 2>/dev/null)

ALEMBIC ?= $(PY_ALEMBIC)

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
