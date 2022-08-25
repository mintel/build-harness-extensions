# You might want to set these when you run make
GRAFANA_ADMIN_PASSWORD ?= admin
LOCAL_DASHBOARD_DIRECTORY ?= $(shell ${BUILD_HARNESS_EXTENSIONS_PATH}/modules/grafana/scripts/local_dashboard_directory_prompt.sh)
BUILD_HARNESS_EXTENSIONS_PRIVATE_BRANCH ?= main
CREATE_GRAFANA_INSTANCE ?= true
GRAFANA_IMAGE ?= grafana/grafana:8.4.2

# Generally no reason to change these defaults, but values don't matter as long as they're different from eachother
GRAFANA_LOCAL_DOCKER_NAME = grafana_local
GRAFANA_SYNC_DOCKER_NAME = grafana_sync

# Don't change these, unless you understand how they're used in the scripts below and accept the repurcussions
CONTAINER_DASHBOARD_DIRECTORY = /app/dashboards
TMP_GITLAB_REPO_DIRECTORY = /tmp/build-harness-extensions-private

.PHONY: grafana/develop grafana/develop-oss grafana/cleanup grafana/aws-profile-check grafana/private grafana/setup-local-grafana-mintel grafana/setup-local-grafana-oss grafana/setup-grafana-syncer

ifeq (${CREATE_GRAFANA_INSTANCE}, true)
## Develop grafana dashboards using live datasources. Mintel internal use only.
grafana/develop: grafana/cleanup grafana/setup-local-grafana-mintel grafana/setup-grafana-syncer
## Develop grafana dashboards without setting up datasources.
grafana/develop-oss: grafana/cleanup grafana/setup-local-grafana-oss grafana/setup-grafana-syncer
else
## Set the CREATE_GRAFANA_INSTANCE variable to false if you already have a localhost:3000 grafana instance and just want to run the syncer
grafana/develop: grafana/setup-grafana-syncer
grafana/develop-oss: grafana/setup-grafana-syncer
endif

## Cleanup docker containers and files associated with grafana/develop
grafana/cleanup:
	@echo "Killing ${GRAFANA_LOCAL_DOCKER_NAME}..."
	@docker kill ${GRAFANA_LOCAL_DOCKER_NAME} || true
	@echo "Killing ${GRAFANA_SYNC_DOCKER_NAME}..."
	@docker kill ${GRAFANA_SYNC_DOCKER_NAME} || true
	@echo "Removing ${TMP_GITLAB_REPO_DIRECTORY}..."
	@rm -rf ${TMP_GITLAB_REPO_DIRECTORY}
	@echo "Cleanup successful."

grafana/aws-profile-check:
	@[ "${AWS_PROFILE}" ] || ( echo ">> ERROR: AWS_PROFILE is not set. Please login with \"aws sso login --profile <name>\" and set this variable, or try \"make grafana/develop-oss\" to edit dashboards with no datasources defined."; exit 1 )
	@echo "AWS_PROFILE=${AWS_PROFILE}"

grafana/private:
	@git clone git@gitlab.com:mintel/satoshi/tools/build-harness-extensions-private.git -b ${BUILD_HARNESS_EXTENSIONS_PRIVATE_BRANCH} ${TMP_GITLAB_REPO_DIRECTORY}

grafana/setup-local-grafana-mintel: grafana/aws-profile-check grafana/private
	@docker pull $(GRAFANA_IMAGE)
	@. ${TMP_GITLAB_REPO_DIRECTORY}/modules/grafana/datasource_credentials.sh && \
	docker run --rm -d -p 3000:3000 --user $(id):$(id) -v ${TMP_GITLAB_REPO_DIRECTORY}/modules/grafana/provisioning:/etc/grafana/provisioning -v ${HOME}/.aws:/usr/share/grafana/.aws --env-file ${TMP_GITLAB_REPO_DIRECTORY}/modules/grafana/env.list -e GF_AUTH_ANONYMOUS_ORG_ROLE=Admin -e GF_AUTH_ANONYMOUS_ENABLED=true -e AWS_PROFILE=${AWS_PROFILE} -e AWS_SDK_LOAD_CONFIG=true -e AWS_EC2_METADATA_DISABLED=1 --name ${GRAFANA_LOCAL_DOCKER_NAME} $(GRAFANA_IMAGE)
grafana/setup-local-grafana-oss:
	@docker pull $(GRAFANA_IMAGE)
	@docker run --rm -d -p 3000:3000 --name ${GRAFANA_LOCAL_DOCKER_NAME} $(GRAFANA_IMAGE)

grafana/setup-grafana-syncer:
ifeq (${CREATE_GRAFANA_INSTANCE}, true)
# Give the grafana instance time to start up before changing the admin password in order to avoid errors
	@echo "Starting grafana on localhost:3000 ..."
	@sleep 3s
	@docker exec -it ${GRAFANA_LOCAL_DOCKER_NAME} grafana-cli --homepath "/usr/share/grafana" admin reset-admin-password ${GRAFANA_ADMIN_PASSWORD}
endif
	@docker pull mintel/grafana-local-sync:latest
	@docker run --rm -it --mount type=bind,source=$$PWD/${LOCAL_DASHBOARD_DIRECTORY},target=${CONTAINER_DASHBOARD_DIRECTORY}/LocalDev --network="host" --name ${GRAFANA_SYNC_DOCKER_NAME} mintel/grafana-local-sync:latest -user admin -pass ${GRAFANA_ADMIN_PASSWORD} -dir ${CONTAINER_DASHBOARD_DIRECTORY}
	@$(MAKE) grafana/cleanup
