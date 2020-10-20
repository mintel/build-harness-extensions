# build-harness-extensions

A collection of build-harness extensions

## Usage

See https://github.com/cloudposse/build-harness#extending-build-harness-with-targets-from-another-repo


As an example, you could `git-submodule` this into your repo (into the `build-harness-extensions` dir) then use the following:

```sh
export HELP_FILTER ?= git/submodules-update|jsonnet|kind|opa|pluto|tanka
-include $(shell curl -sSL -o .build-harness "https://git.io/build-harness"; echo .build-harness)
export BUILD_HARNESS_PATH ?= $(shell 'pwd')
export BUILD_HARNESS_EXTENSIONS_PATH ?= $(BUILD_HARNESS_PATH)/build-harness-extensions
```

## Targets

```
  git/submodules-update               Update submodules
  jsonnet/diff                        Diff Jsonnet fils against expected golden 
  jsonnet/diff-help                   Help regarding Jsonnet diff
  jsonnet/gen-golden                  Generate expected golden files from Jsonnet
  jsonnet/test                        Run Jsonnet tests
  kind/create                         Start KinD local cluster
  kind/delete                         Delete KinD local cluster
  kind/up                             Install jsonnetfile.json with jsonnet-bundler
  opa/clone-policy                    Git clone policies (requires OPA_POLICIES_REPO argument)
  opa/conftest                        Validate manifests
  pluto/validate                      Validate manifests
  tanka/fmt                           Format Jsonnet files with tanka
  tanka/generate                      Generate manifests using tanka
  tanka/to-kustomize                  Generate kustomization for tanka-generated manifests
  ```
