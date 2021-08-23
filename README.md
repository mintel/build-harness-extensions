# build-harness-extensions

A collection of build-harness extensions

## Usage

See https://github.com/cloudposse/build-harness#extending-build-harness-with-targets-from-another-repo


As an example, you could `git-submodule` this into your repo (into the `build-harness-extensions` dir) then use the following:

```sh
export HELP_FILTER ?= git/submodules-update|jsonnet|kind|kubecfg|kubeval|opa|tanka
-include $(shell curl -sSL -o .build-harness "https://git.io/build-harness"; echo .build-harness)
export BUILD_HARNESS_PATH ?= $(shell 'pwd')
export BUILD_HARNESS_EXTENSIONS_PATH ?= $(BUILD_HARNESS_PATH)/build-harness-extensions
```

## Targets

```
  alembic/current                     Display the current revision of alembic migrations
  alembic/history                     List changeset scripts in chronological order
  alembic/upgrade                     Apply alembic migrations to the latest revision
  asdf/install                        Installing required tools
  git/submodules-update               Update submodules
  jsonnet/diff                        Diff Jsonnet fils against expected golden 
  jsonnet/diff-help                   Help regarding Jsonnet diff
  jsonnet/gen-golden                  Generate expected golden files from Jsonnet
  jsonnet/install                     Install packages from jsonnetfile.json with jsonnet-bundler
  jsonnet/rm-golden                   Remove golden files from Jsonnet
  jsonnet/test                        Run Jsonnet tests
  jsonnet/update                      Update packages from jsonnetfile.json with jsonnet-bundler
  kind/create                         Start KinD local cluster
  kind/delete                         Delete KinD local cluster
  kubecfg/validate                    Validate manifests
  kubeval/validate                    Validate manifests
  opa/clone-policy                    Git clone policies (requires OPA_POLICY_REPO argument)
  opa/conftest                        Validate manifests
  satoshi/check-asdf-dep              Check dependencies (installer) for Satoshi
  satoshi/check-deps                  Check dependencies for Satoshi
  satoshi/update-makefile             Update Satoshi Makefile
  satoshi/update-tools                Update Satoshi asdf .tool-versions
  pluto/validate                      Validate manifests
  poetry/check                        Validate the structure of pyproject.toml
  poetry/install                      Install Poetry dependencies
  poetry/lock                         Lock Poetry dependencies
  poetry/auth/%                       HTTP Basic authenticate to source for Poetry
  pytest                              Run Python tests with pytest
  python/autoflake                    Fix python imports ordering using autoflake
  python/autoflake/check              Check python imports ordering using autoflake
  python/black                        Reformat python files using black
  python/black/check                  Check python files using black
  python/clean                        Clean all unecessary python project files
  python/flake8                       Check python style against pep8 using flake8
  python/isort                        Fix python imports using isort
  python/isort/check                  Check python imports using isort
  python/mypy/check                   Check python files statically using mypy
  tanka/fmt                           Format Jsonnet files with tanka
  tanka/fmt-test                      Test formatting of Jsonnet files and exit with non-zero when changes would be made
  tanka/generate                      Generate manifests using tanka including support for kustomize
```
