## Packer helpers
.PHONY: packer/update-sources
## Pulls in the current version of the `sources.pkr.hcl` file from the packer-repo template
packer/update-sources:
	# TODO: Figure out what to do with token
	$(shell curl --header "PRIVATE-TOKEN: <TOKEN>" -sSL -o sources.pkr.hcl "https://gitlab.com/api/v4/projects/57900554/repository/files/sources.pkr.hcl/raw?ref=develop")
