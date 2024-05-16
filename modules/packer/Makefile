## Packer helpers
PACKER_REPO_BRANCH?=main
PACKER_REPO?=git@gitlab.com:mintel/satoshi/templates/packer-repo.git
PACKER_REPO_DIR=/tmp/packer-repo
PACKER_SOURCE_FILE="sources.pkr.hcl"

.PHONY: packer/update-sources
## Pulls in the current version of the `sources.pkr.hcl` file from the packer-repo template
packer/update-sources:
	@echo "Cloning packer-repo: "${PACKER_REPO}""
	@if [ -f "$(PACKER_SOURCE_FILE)" ]; then \
		rm -rf $(PACKER_SOURCE_FILE) ;\
	fi ;\
	git clone --depth=1 $(PACKER_REPO) -b $(PACKER_REPO_BRANCH) $(PACKER_REPO_DIR) ;\
	echo "Copying "${PACKER_SOURCE_FILE}""
	cp "${PACKER_REPO_DIR}/${PACKER_SOURCE_FILE}" "${PACKER_SOURCE_FILE}"
	echo "Cleanup cloned dir ${PACKER_REPO_DIR}"
	rm -rf ${PACKER_REPO_DIR}
