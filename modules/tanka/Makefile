## Tanka helpers
ENVIRONMENTS=$(shell find environments/ -type f -name "main.jsonnet")
TANKA_EXPORT_FMT?={{.apiVersion}}.{{.kind}}-{{ if.metadata.namespace}}{{.metadata.namespace }}-{{end}}{{.metadata.name }}

## Format Jsonnet files with tanka
tanka/fmt:
	@@if ! tk fmt . ; then \
	  exit 1;\
	fi
  
## Generate manifests using tanka
tanka/generate:
	@echo ;\
	echo "Generating rendered manifests in ./rendered" ;\
	echo "Run 'make jsonnet/[install|update]' beforehand if you require vendor package installation" ;\
	echo ;\
	mkdir -p $$(pwd)/rendered/ ;\
	touch $$(pwd)/rendered/.gitkeep ;\
	for f in $(ENVIRONMENTS); do \
		env_path="$$(dirname $$f)" ;\
		echo "Generating $${env_path}" ;\
		mkdir -p ./rendered/$${env_path} ;\
		pushd ./rendered/$${env_path} > /dev/null || exit 1 ;\
		touch kustomization.yaml ;\
		yq -i eval 'del(.resources)' kustomization.yaml ;\
		rm -rf ./manifests/*.yaml ;\
		tk export --format='$(TANKA_EXPORT_FMT)' $(BUILD_HARNESS_PATH)/$${env_path} ./manifests > /dev/null ;\
 		kustomize edit add resource ./manifests/*.yaml ;\
		popd > /dev/null || exit 1 ;\
	done
