## asdf helpers
ASDF_ROOT := ${HOME}/.asdf
ASDF_REPO_DIR=$(shell pwd)

## Generate .tool-versions
ASDF_PKGS = \
	"awscli 2.1.39" \
	"aws-vault 6.3.0" \
	"conftest v0.23.0" \
	"jq 1.6" \
	"go-jsonnet 0.17.0" \
	"jb 0.4.0" \
	"kubectl 1.19.9" \
	"kubergrunt 0.6.10" \
	"kustomize 3.8.1" \
	"opa 0.26.0" \
	"pluto 4.0.4" \
	"tanka 0.13.0" \
	"terraform 0.13.5" \
	"terraform-docs 0.10.1" \
	"terragrunt 0.26.7" \
	"yq v4.6.2"

## Generate ASDF .tool-versions file
asdf/generate:
	@@rm -f ${ASDF_REPO_DIR}/.tool-versions
	@@for pkg in $(ASDF_PKGS); do \
		echo $$pkg >> .tool-versions ;\
	done

## Installing required tools
asdf/install: asdf/generate
	test -s $(ASDF_ROOT) || git clone https://github.com/asdf-vm/asdf.git $(ASDF_ROOT) ;\
	asdf plugin-add aws-vault https://github.com/virtualstaticvoid/asdf-aws-vault.git ;\
	asdf plugin-add kubergrunt https://github.com/nuxlli/asdf-kubergrunt.git ;\
	asdf plugin-add jq https://github.com/ryodocx/asdf-jq.git ;\
	cat ${ASDF_REPO_DIR}/.tool-versions | cut -d' ' -f1 | xargs -I_pkg -- sh -c 'asdf plugin add _pkg ; asdf install _pkg'
