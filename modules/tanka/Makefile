## Tanka helpers
ENVIRONMENTS=$(shell find environments/ -type f -name "spec.json")

## Format Jsonnet files with tanka
tanka/fmt:
	@@if ! tk fmt . ; then \
	  exit 1;\
	fi
  
## Generate manifests using tanka
tanka/generate:
	@echo "Generating rendered manifests in ./rendered" ;\
	rm -rf $$(pwd)/rendered/ ;\
	mkdir -p $$(pwd)/rendered/ ;\
	touch $$(pwd)/rendered/.gitkeep ;\

	@for f in $(ENVIRONMENTS); do \
	    app_path="$$(dirname $$f)" ;\
	    rendered_path="./rendered/$${app_path}/manifests" ;\
	    mkdir -p $${rendered_path} ;\
	    tk export $$(dirname $$f) $${rendered_path} > /dev/null ;\
	done

## Generate kustomization for tanka-generated manifests
tanka/to-kustomize: tanka/generate
	@for f in $(ENVIRONMENTS); do \
		app_path="$$(dirname $$f)" ;\
		rendered_path="./rendered/$${app_path}" ;\
		echo $${pwd} ;\
		pushd $${rendered_path} > /dev/null || exit 1 ;\
		rm -f kustomization.yaml && touch kustomization.yaml ;\
 		kustomize edit add resource ./manifests/*.yaml ;\
		popd > /dev/null || exit 1 ;\
	done
