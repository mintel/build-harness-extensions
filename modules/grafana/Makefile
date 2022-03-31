# You might want to set these when you run make
GRAFANA_ADMIN_PASSWORD ?= admin
LOCAL_DASHBOARD_DIRECTORY ?= $(shell ${BUILD_HARNESS_EXTENSIONS_PATH}/modules/grafana/scripts/local_dashboard_directory_prompt.sh)
BUILD_HARNESS_EXTENSIONS_PRIVATE_BRANCH ?= main

# Generally no reason to change these defaults, but values don't matter as long as they're different from eachother
GRAFANA_LOCAL_DOCKER_NAME = grafana_local
GRAFANA_SYNC_DOCKER_NAME = grafana_sync

# Don't change these, unless you understand how they're used in the scripts below and accept the repurcussions
CONTAINER_DASHBOARD_DIRECTORY = /app/dashboards
TMP_GITLAB_REPO_DIRECTORY = /tmp/build-harness-extensions-private

.PHONY: grafana/develop
# Start up a local grafana instance with live datasources, and sync to dashboards on your local disk. Only for mintel internal access, try grafana/develop-oss for general use.
grafana/develop: grafana/cleanup grafana/setup-local-grafana-mintel grafana/setup-grafana-syncer

.PHONY: grafana/develop-oss
# Start up a local grafana instance with no datasources configured, and sync to dashboards on your local disk
grafana/develop-oss: grafana/cleanup grafana/setup-local-grafana-oss grafana/setup-grafana-syncer

grafana/private:
	@git clone git@gitlab.com:mintel/satoshi/tools/build-harness-extensions-private.git -b ${BUILD_HARNESS_EXTENSIONS_PRIVATE_BRANCH} ${TMP_GITLAB_REPO_DIRECTORY}

grafana/setup-local-grafana-mintel: grafana/private
	@. ${TMP_GITLAB_REPO_DIRECTORY}/modules/grafana/datasource_credentials.sh && \
	docker run --rm -d -p 3000:3000 -v ${TMP_GITLAB_REPO_DIRECTORY}/modules/grafana/provisioning:/etc/grafana/provisioning --env-file ${TMP_GITLAB_REPO_DIRECTORY}/modules/grafana/env.list --name ${GRAFANA_LOCAL_DOCKER_NAME} grafana/grafana:latest

grafana/setup-local-grafana-oss:
	@docker run --rm -d -p 3000:3000 --name ${GRAFANA_LOCAL_DOCKER_NAME} grafana/grafana:latest

grafana/setup-grafana-syncer:
# Give the grafana instance time to start up before changing the admin password in order to avoid errors
	@echo "Starting grafana on localhost:3000 ..."
	@sleep 3s
	@docker exec -it ${GRAFANA_LOCAL_DOCKER_NAME} grafana-cli --homepath "/usr/share/grafana" admin reset-admin-password ${GRAFANA_ADMIN_PASSWORD}
	@docker run --rm -it --mount type=bind,source=$$PWD/${LOCAL_DASHBOARD_DIRECTORY},target=${CONTAINER_DASHBOARD_DIRECTORY}/LocalDev --network="host" --name ${GRAFANA_SYNC_DOCKER_NAME} mintel/grafana-local-sync:latest -user admin -pass ${GRAFANA_ADMIN_PASSWORD} -dir ${CONTAINER_DASHBOARD_DIRECTORY}
	@$(MAKE) grafana/cleanup

.PHONY: grafana/cleanup
# Kill any docker containers associated with grafana/develop, and remove anything added to /tmp
grafana/cleanup:
	@echo "Killing ${GRAFANA_LOCAL_DOCKER_NAME}..."
	@docker kill ${GRAFANA_LOCAL_DOCKER_NAME} || true
	@echo "Killing ${GRAFANA_SYNC_DOCKER_NAME}..."
	@docker kill ${GRAFANA_SYNC_DOCKER_NAME} || true
	@echo "Removing ${TMP_GITLAB_REPO_DIRECTORY}..."
	@rm -rf ${TMP_GITLAB_REPO_DIRECTORY}
	@echo "Cleanup successful."
