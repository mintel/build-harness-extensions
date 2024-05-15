## Packer helpers
.PHONY: packer/update-sources
## Pulls in the current version of the `sources.pkr.hcl` file from the packer-repo template
packer/update-sources:
	$(shell curl -sSL -o .sources.pkr.hcl "https://gitlab.com/mintel/satoshi/templates/packer-repo/-/raw/develop/sources.pkr.hcl")
