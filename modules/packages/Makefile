export INSTALL_PATH = $(BUILD_HARNESS_PATH)/vendor
export PACKAGES_VERSION = master
export PACKAGES_PATH = $(BUILD_HARNESS_PATH)/vendor/packages
export PACKAGES_VENDOR ?= cloudposse
export PACKAGES_REPO ?= packages.git

## Install packages
packages/install:
	@if [ ! -d $(PACKAGES_PATH) ]; then \
	  echo "Installing packages ref=$(PACKAGES_VERSION)..."; \
	  rm -rf $(PACKAGES_PATH); \
	  $(GIT) clone -c advice.detachedHead=false --depth=1 -b $(PACKAGES_VERSION) https://github.com/$(PACKAGES_VENDOR)/$(PACKAGES_REPO) $(PACKAGES_PATH); \
	  rm -rf $(PACKAGES_PATH)/.git; \
	fi
