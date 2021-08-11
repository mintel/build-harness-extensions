## Tanka helpers
MAKEFILE_PATH := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

## Format Jsonnet files with tanka
tanka/fmt: satoshi/check-deps
	tk fmt .

## Test formatting of Jsonnet files and exit with non-zero when changes would be made
tanka/fmt-test: satoshi/check-deps
	tk fmt --test .

## Generate manifests using tanka
tanka/generate: satoshi/check-deps
	$(MAKEFILE_PATH)/generate.sh $(app) $(env)
