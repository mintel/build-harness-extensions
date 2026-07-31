RELEASE_TAG ?= 1.0.0
dirs ?= rendered/
env ?=
app ?= ""

dev_dir = rendered/environments/aws.dev
qa_dir = rendered/environments/aws.qa
logs_dir = rendered/environments/aws.logs
prod_dir = rendered/environments/aws.prod

.PHONY: updater/test check-prereq-variables get-dirs

## Test argocd-image-updater annotations
updater/test: check-prereq-variables get-dirs
	@echo $(dirs)
	@mkdir -p bin
	@wget -O bin/argocd-image-updater-tester --header "PRIVATE-TOKEN: $(word 2,$(subst :, ,$(GITLAB_SECRET)))" https://gitlab.com/api/v4/projects/37621397/packages/generic/argocd-image-updater-tester/${RELEASE_TAG}/argocd-image-updater-tester
	@chmod +x bin/argocd-image-updater-tester
	@bin/argocd-image-updater-tester --dirs=${dir} --apps=${app}
	@rm bin/argocd-image-updater-tester
	@rm bin/argocd-image-updater
	@rm -d bin

check-prereq-variables:
	@[ "${GITLAB_SECRET}" ] || ( echo -e "ERROR: GITLAB_SECRET environment variable is not defined. Set the variable before running.\nexport GITLAB_SECRET=\"<gitlab_username>:<gitlab_token>\"\nhttps://argocd-image-updater.readthedocs.io/en/stable/basics/authentication/#using-an-environment-variable"; exit 1 )

get-dirs:
ifdef env
$(eval dirs := $())
$(foreach e,$(env),$(eval dirs+=$($(e)_dir)))
endif
