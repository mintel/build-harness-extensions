dbt/init:
	dbt deps
.PHONY: dbt/init

dbt/docs:
	dbt docs generate
.PHONY: dbt/docs

dbt/run:
	dbt run
.PHONY: dbt/run

dbt/seed:
	dbt seed
.PHONY: dbt/seed

dbt/test:
	dbt test
.PHONY: dbt/test

dbt/clean: clean-target clean-logs
.PHONY: dbt/clean

dbt/clean-target:
	rm -rf target/*
.PHONY: dbt/clean-target

dbt/clean-logs:
	rm -rf logs/*
.PHONY: dbt/clean-logs
