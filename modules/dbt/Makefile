# Perform basic dbt init, namely, install/update dependencies
# It is assumed that `dbt init` has been run by this point by the repo creator
dbt/init:
	dbt deps
.PHONY: dbt/init

# Compile dbt code and error out on any warnings
dbt/compile:
	dbt --warn-error compile
.PHONY: dbt/compile

# Generate docs from any existing model definitions and configurations
dbt/docs:
	dbt docs generate
.PHONY: dbt/docs

# Run all dbt models
dbt/run:
	dbt run
.PHONY: dbt/run

# Upload all dbt seeds
dbt/seed:
	dbt seed
.PHONY: dbt/seed

# Run tests for all dbt models
dbt/test:
	dbt test
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
