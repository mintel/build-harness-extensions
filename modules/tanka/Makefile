## Tanka helpers
MAKEFILE_PATH := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: tanka/fmt tanka/fmt-test tanka/lint tanka/generate

## Format Jsonnet files with tanka
tanka/fmt: satoshi/check-deps
	make k8s/tanka/fmt

## Test formatting of Jsonnet files and exit with non-zero when changes would be made
tanka/fmt-test: satoshi/check-deps
	make k8s/tanka/fmt-test

## Generate manifests using tanka
tanka/generate: satoshi/check-deps
	make k8s/tanka/generate

## Lint Jsonnet files with tanka
tanka/lint: satoshi/check-deps
	make k8s/tanka/lint
