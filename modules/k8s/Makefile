## Generic kubernetes helpers
MAKEFILE_PATH := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: k8s/create-ns

## Create required namespaces in local cluster
k8s/create-ns:
	$(MAKEFILE_PATH)/create-ns.sh
