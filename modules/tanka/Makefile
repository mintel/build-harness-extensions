## Tanka helpers
ENVIRONMENTS=$(shell find environments/ -type f -name "main.jsonnet")
TANKA_EXPORT_FMT?={{.apiVersion}}.{{.kind}}-{{ if.metadata.namespace}}{{.metadata.namespace }}-{{end}}{{.metadata.name }}
TANKA_REPO_DIR=$(shell pwd)

## Format Jsonnet files with tanka
tanka/fmt:
	tk fmt .

## Test formatting of Jsonnet files and exit with non-zero when changes would be made
tanka/fmt-test:
	tk fmt --test .

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
		tk export --format='$(TANKA_EXPORT_FMT)' $(TANKA_REPO_DIR)/$${env_path} ./manifests > /dev/null ;\
 		kustomize edit add resource ./manifests/*.yaml ;\
		popd > /dev/null || exit 1 ;\
	done
