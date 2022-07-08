RELEASE_TAG ?= 0.1.0
.PHONY: updater/test check-prereq-variables

## Test argocd-image-updater annotations
updater/test: check-prereq-variables
	@wget --directory-prefix bin --header "PRIVATE-TOKEN: $(word 2,$(subst :, ,$(GITLAB_SECRET)))" https://gitlab.com/api/v4/projects/37621397/packages/generic/argocd-image-updater-tester/${RELEASE_TAG}/argocd-image-updater-tester
	@chmod +x bin/argocd-image-updater-tester
	@bin/argocd-image-updater-tester
	@rm bin/argocd-image-updater-tester
	@rm -d bin

check-prereq-variables:
	@[ "${GITLAB_SECRET}" ] || ( echo -e "ERROR: GITLAB_SECRET environment variable is not defined. Set the variable before running.\nexport GITLAB_SECRET=\"<gitlab_username>:<gitlab_token>\"\nhttps://argocd-image-updater.readthedocs.io/en/stable/basics/authentication/#using-an-environment-variable"; exit 1 )
