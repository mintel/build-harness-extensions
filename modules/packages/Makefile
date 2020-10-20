export INSTALL_PATH = $(BUILD_HARNESS_PATH)/vendor
export PACKAGES_VERSION = nb-all
export PACKAGES_PATH = $(BUILD_HARNESS_PATH)/vendor/packages

## Install packages 
packages/install:
	@if [ ! -d $(PACKAGES_PATH) ]; then \
	  echo "Installing packages $(PACKAGES_VERSION)..."; \
	  rm -rf $(PACKAGES_PATH); \
	  $(GIT) clone -c advice.detachedHead=false --depth=1 -b $(PACKAGES_VERSION) https://github.com/nabadger/packages.git $(PACKAGES_PATH); \
	  rm -rf $(PACKAGES_PATH)/.git; \
	fi 
