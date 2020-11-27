## Jsonnet helpers
JSONNET_ARGS=-J ./lib -J ./vendor -J .
JSONNET_TEST_FILES=$(wildcard ./*/tests/test.jsonnet)
JSONNET_GOLDEN_FILES=$(wildcard ./*/tests/test-golden.json)
JSONNET_PHONY_GOLDEN=$(patsubst %.jsonnet,%-golden.json,$(JSONNET_TEST_FILES))
JSONNET_PHONY_DIFF=$(patsubst %.jsonnet,%.diff,$(JSONNET_TEST_FILES))
JSONNETFILE_DIRS=$(dir $(wildcard ./environments/*/jsonnetfile.json) $(wildcard jsonnetfile.json))

.PHONY: jsonnet/install
## Install packages from jsonnetfile.json with jsonnet-bundler
jsonnet/install:
	@for dir in $(JSONNETFILE_DIRS); do \
		set -e; \
		pushd $$dir >/dev/null; \
		echo "Running JB install in $$dir"; \
		jb install; \
		popd >/dev/null; \
		set +e; \
	done

.PHONY: jsonnet/update
## Update packages from jsonnetfile.json with jsonnet-bundler
jsonnet/update:
	@for dir in $(JSONNETFILE_DIRS); do \
		set -e; \
		pushd $$dir >/dev/null; \
		echo "Running JB update in $$dir"; \
		jb update; \
		popd >/dev/null; \
		set +e; \
	done

.PHONY: jsonnet/test
## Run Jsonnet tests
jsonnet/test: jsonnet/install jsonnet/diff

.PHONY: jsonnet/diff
## Diff Jsonnet fils against expected golden 
jsonnet/diff: jsonnet/diff-help $(JSONNET_PHONY_DIFF)

%.diff: %.jsonnet
	diff -u $(*)-golden.json <(jsonnet $(JSONNET_ARGS) $(<))

%-golden.json: %.jsonnet
	jsonnet $(JSONNET_ARGS) $(<) > $(@)

.PHONY: jsonnet/rm-golden
## Remove golden files from Jsonnet
jsonnet/rm-golden:
	rm -f $(JSONNET_GOLDEN_FILES)

.PHONY: jsonnet/gen-golden
## Generate expected golden files from Jsonnet
jsonnet/gen-golden: jsonnet/rm-golden $(JSONNET_PHONY_GOLDEN)

.PHONY: jsonnet/diff-help
## Help regarding Jsonnet diff
jsonnet/diff-help:
	@echo "NOTE: if the 'jsonnet/diff' target fails, review output and run:"
	@echo "      $(MAKE) jsonnet/gen-golden jsonnet/diff"
	@echo
