# build-harness-extensions

A collection of build-harness extensions

## Usage

See https://github.com/cloudposse/build-harness#extending-build-harness-with-targets-from-another-repo


As an example, you could `git-submodule` this into your repo (into the `build-harness-extensions` dir) then use the following:

```sh
export HELP_FILTER ?= git/submodules-update|jsonnet|k8s|opa
-include $(shell curl -sSL -o .build-harness "https://raw.githubusercontent.com/cloudposse/build-harness/HEAD/templates/Makefile.build-harness"; echo .build-harness)
export BUILD_HARNESS_PATH ?= $(shell 'pwd')
export BUILD_HARNESS_EXTENSIONS_PATH ?= $(BUILD_HARNESS_PATH)/build-harness-extensions
```

## Targets

```
  alembic/current                     Display the current revision of alembic migrations
  alembic/history                     List changeset scripts in chronological order
  alembic/upgrade                     Apply alembic migrations to the latest revision
  asdf/install                        Installing required tools
  dbt/clean                           Clean up dbt logs and compiled code
  dbt/compile                         Compile dbt code for future use
  dbt/docs                            Generate documentation for your dbt project
  dbt/init                            Installing dbt dependencies
  dbt/run                             Run dbt against all models
  dbt/sqlfluff/fmt                    Reformat dbt code using sqlfluff
  dbt/sqlfluff/lint                   Check dbt code using sqlfluff
  dbt/partial_run                     Run dbt against modeles changed since last compilation
  dbt/partial_test                    Run dbt tests against modeles changed since last compilation
  dbt/seed                            Upload dbt seeds
  dbt/test                            Run dbt tests against all models
  git/submodules-update               Update submodules
  grafana/cleanup                     Cleanup docker containers and files associated with grafana/develop
  grafana/develop                     Develop grafana dashboards using live datasources. Mintel internal use only.
  grafana/develop-oss                 Develop grafana dashboards without setting up datasources.
  jsonnet/diff                        Diff Jsonnet fils against expected golden
  jsonnet/diff-help                   Help regarding Jsonnet diff
  jsonnet/gen-golden                  Generate expected golden files from Jsonnet
  jsonnet/install                     Install packages from jsonnetfile.json with jsonnet-bundler
  jsonnet/rm-golden                   Remove golden files from Jsonnet
  jsonnet/test                        Run Jsonnet tests
  jsonnet/update                      Update packages from jsonnetfile.json with jsonnet-bundler
  k8s/cluster/create                  Create a local Kubernetes cluster
  k8s/cluster/delete                  Delete a local Kubernetes cluster
  k8s/cluster/down                    Stops an existing local Kubernetes cluster
  k8s/cluster/up                      Starts an existing local Kubernetes cluster
  k8s/create-ns                       Creates required namespaces for the repo in the cluster
  k8s/kubecfg/validate                Validate manifests
  k8s/kubeval/validate                Validate manifests
  k8s/tanka/apply/%                   Apply rendered manifests of an app to the local cluster
  k8s/tanka/delete/%                  Removes rendered manifests of an app from the local cluster
  k8s/tanka/fmt                       Format Jsonnet files with tanka
  k8s/tanka/fmt-test                  Test formatting of Jsonnet files and exit with non-zero when changes would be made
  k8s/tanka/generate                  Generate manifests using tanka including support for kustomize
  opa/clone-policy                    Git clone policies (requires OPA_POLICY_REPO argument)
  opa/conftest                        Validate manifests
  satoshi/check-asdf-dep              Check dependencies (installer) for Satoshi
  satoshi/check-deps                  Check dependencies for Satoshi
  satoshi/update-makefile             Update Satoshi Makefile for k8s toolset
  satoshi/update-makefile/%           Update Satoshi Makefile for a particular toolset e.g. k8s and tf
  satoshi/update-tools                Update Satoshi asdf .tool-versions for k8s related repo
  satoshi/update-tools/%              Update Satoshi asdf .tool-versions for a particular toolset e.g. k8s and tf
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
```
