## Tanka helpers
TANKA_CONTAINER_CMD:=docker run --rm \
  -u="$(shell id -u):$(shell id -g)" \
  -v $$(pwd):/src/ \
  --workdir /src/ \
  grafana/tanka:latest

TANKA_ALL_ENVIRONMENTS = $(shell find environments/ -type f -name "spec.json")


## Format Jsonnet files with tanka
tanka/fmt:
	@@if ! $(TANKA_CONTAINER_CMD) fmt . ; then \
	  exit 1;\
	fi
  
## Generate manifests using tanka
tanka/generate:
	@echo "Generating rendered manifests in ./rendered" ;\
  rm -rf $$(pwd)/rendered/ ;\
	mkdir -p $$(pwd)/rendered/ ;\
	touch $$(pwd)/rendered/.gitkeep ;\

	@for f in $(TANKA_ALL_ENVIRONMENTS); do \
	    app_path="$$(dirname $$f)" ;\
	    rendered_path="./rendered/$${app_path}/manifests" ;\
	    mkdir -p $${rendered_path} ;\
	    tk export $$(dirname $$f) $${rendered_path} > /dev/null ;\
	done

## Generate kustomization for tanka-generated manifests
tanka/to-kustomize: tanka/generate
	@for f in $(TANKA_ALL_ENVIRONMENTS); do \
		app_path="$$(dirname $$f)" ;\
		rendered_path="./rendered/$${app_path}" ;\
		echo $${pwd} ;\
		pushd $${rendered_path} > /dev/null || exit 1 ;\
		rm -f kustomization.yaml && touch kustomization.yaml ;\
 		kustomize edit add resource ./manifests/*.yaml ;\
		popd > /dev/null || exit 1 ;\
	done
