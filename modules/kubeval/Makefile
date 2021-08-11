## Kubeval helpers
KUBEVAL_K8S_VERSION?=1.16.4
KUBEVAL_IGNORE_FILENAME_PATTERNS?=kustomization.yaml
KUBEVAL_ARGS?=--strict --quiet --output tap --ignore-missing-schemas --ignored-filename-patterns $(KUBEVAL_IGNORE_FILENAME_PATTERNS)
K8S_RENDERED_DIR?=./rendered/environments

.PHONY: kubeval/validate

## Validate manifests
kubeval/validate:
	kubeval $(KUBEVAL_ARGS) --kubernetes-version $(KUBEVAL_K8S_VERSION) -d $(K8S_RENDERED_DIR)
