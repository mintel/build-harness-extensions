# Perform basic dbt init, namely, install/update dependencies
# It is assumed that `dbt init` has been run by this point by the repo creator
dbt/init:
	dbt deps
.PHONY: dbt/init

# Compile all dbt code in strict mode
dbt/compile:
	dbt compile --strict
.PHONY: dbt/compile

DBT_PRE_COMPILED = target/manifest.json target/graph.gpickle target/partial_parse.msgpack

${DBT_PRE_COMPILED}:
	dbt compile --strict

# Run all dbt models
dbt/run: ${DBT_PRE_COMPILED}
	dbt --partial-parse run
.PHONY: dbt/run

# Generate docs from all existing model definitions and configurations
dbt/docs: ${DBT_PRE_COMPILED}
	dbt --partial-parse docs generate
.PHONY: dbt/docs

# Upload all dbt seeds
dbt/seed: ${DBT_PRE_COMPILED}
	dbt --partial-parse seed
.PHONY: dbt/seed

# Run tests for all dbt models
dbt/test: ${DBT_PRE_COMPILED}
	dbt --partial-parse test
.PHONY: dbt/test

# Run only the models changed since last compilation
dbt/partial_run: ${DBT_PRE_COMPILED}
	dbt --partial-parse run -m @state:modified --state .
.PHONY: dbt/partial_run

# Run only tests on models models changed since last compilation
dbt/partial_test: ${DBT_PRE_COMPILED}
	dbt --partial-parse test -m @state:modified --state .
.PHONY: dbt/test

# Clean up dbt logs and compiled sql in target/
# Needs to be updated if you use different directory
dbt/clean: clean-target clean-logs
.PHONY: dbt/clean

dbt/clean-target:
	rm -rf target/*
.PHONY: dbt/clean-target

dbt/clean-logs:
	rm -rf logs/*
.PHONY: dbt/clean-logs
