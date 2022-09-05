# Install hashicorp sentinel functions
.PHONY: sentinel/pull-hashicorp-functions
sentinel/pull-hashicorp-functions:
	if [ ! -d "./sentinel-extensions" ]; then git submodule add https://github.com/hashicorp/terraform-sentinel-policies.git sentinel-extensions; fi
	git submodule update --init --recursive
