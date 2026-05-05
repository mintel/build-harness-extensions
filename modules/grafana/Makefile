# You might want to set these when you run make
GRAFANA_ADMIN_PASSWORD ?= admin
LOCAL_DASHBOARD_DIRECTORY ?= $(shell ${BUILD_HARNESS_EXTENSIONS_PATH}/modules/grafana/scripts/local_dashboard_directory_prompt.sh)
CORE_CLUSTER_JSONNET_BRANCH ?= main
CREATE_GRAFANA_INSTANCE ?= true
CREATE_GRAFANA_MCP ?= true
GRAFANA_IMAGE ?= grafana/grafana:12.3.1
GRAFANA_PLUGINS ?= natel-discrete-panel,grafana-piechart-panel,grafana-athena-datasource,marcusolsson-json-datasource,yesoreyeram-infinity-datasource
MCP_GRAFANA_IMAGE ?= mcp/grafana:latest
MCP_GRAFANA_PORT ?= 3001
MINTEL_BASE_URL ?= mintel.cloud
# Generally no reason to change these defaults, but values don't matter as long as they're different from eachother
GRAFANA_LOCAL_DOCKER_NAME = grafana_local
GRAFANA_SYNC_DOCKER_NAME = grafana_sync
GRAFANA_MCP_DOCKER_NAME = grafana_mcp

# Don't change these, unless you understand how they're used in the scripts below and accept the repurcussions
CONTAINER_DASHBOARD_DIRECTORY = /app/dashboards
ifeq ($(shell git remote get-url origin),git@gitlab.com:mintel/satoshi/kubernetes/jsonnet/sre/monitoring-cluster-jsonnet.git)
TMP_MONITORING_CLUSTER_JSONNET = .
else
TMP_MONITORING_CLUSTER_JSONNET = /tmp/monitoring-cluster-jsonnet
endif
TMP_GRAFANA_DATASOURCES = /tmp/grafana-datasources.yaml

UID=$(shell id -u)

.PHONY: grafana/develop grafana/develop-oss grafana/cleanup grafana/aws-profile-check grafana/monitoring-cluster-jsonnet grafana/setup-local-grafana-mintel grafana/setup-local-grafana-oss grafana/wait-for-grafana grafana/setup-grafana-mcp grafana/setup-grafana-syncer

ifeq (${CREATE_GRAFANA_INSTANCE}, true)
## Develop grafana dashboards using live datasources. Mintel internal use only.
grafana/develop: grafana/cleanup grafana/setup-local-grafana-mintel grafana/setup-grafana-mcp grafana/setup-grafana-syncer
## Develop grafana dashboards without setting up datasources.
grafana/develop-oss: grafana/cleanup grafana/setup-local-grafana-oss grafana/setup-grafana-mcp grafana/setup-grafana-syncer
else
## Set the CREATE_GRAFANA_INSTANCE variable to false if you already have a localhost:3000 grafana instance and just want to run the syncer
grafana/develop: grafana/setup-grafana-mcp grafana/setup-grafana-syncer
grafana/develop-oss: grafana/setup-grafana-mcp grafana/setup-grafana-syncer
endif

## Cleanup docker containers and files associated with grafana/develop
grafana/cleanup:
	@echo "Killing ${GRAFANA_LOCAL_DOCKER_NAME}..."
	@docker kill ${GRAFANA_LOCAL_DOCKER_NAME} || true
	@echo "Killing ${GRAFANA_MCP_DOCKER_NAME}..."
	@docker kill ${GRAFANA_MCP_DOCKER_NAME} || true
	@echo "Killing ${GRAFANA_SYNC_DOCKER_NAME}..."
	@docker kill ${GRAFANA_SYNC_DOCKER_NAME} || true
	@echo "Removing ${TMP_GRAFANA_DATASOURCES}..."
	@rm -rf ${TMP_GRAFANA_DATASOURCES}
	@echo "Cleanup successful."

grafana/aws-profile-check:
	@[ "${AWS_PROFILE}" ] || ( echo ">> ERROR: AWS_PROFILE is not set. Please login with \"aws sso login --profile <name>\" and set this variable, or try \"make grafana/develop-oss\" to edit dashboards with no datasources defined."; exit 1 )
	@echo "AWS_PROFILE=${AWS_PROFILE}"

grafana/monitoring-cluster-jsonnet:
	@if [ ! -d "$(TMP_MONITORING_CLUSTER_JSONNET)" ]; then \
		git clone git@gitlab.com:mintel/satoshi/kubernetes/jsonnet/sre/monitoring-cluster-jsonnet.git --depth 1 -b ${CORE_CLUSTER_JSONNET_BRANCH} ${TMP_MONITORING_CLUSTER_JSONNET}; \
	fi
ifeq ($(TMP_MONITORING_CLUSTER_JSONNET),.)
	# You are developing in monitoring-cluster-jsonnet; using local grafana-operator manifests to set up Grafana datasources.
else
	@git -C "$(TMP_MONITORING_CLUSTER_JSONNET)" pull
endif

grafana/setup-local-grafana-mintel: grafana/aws-profile-check grafana/monitoring-cluster-jsonnet
	@docker pull $(GRAFANA_IMAGE)
	@mkdir -p ${TMP_MONITORING_CLUSTER_JSONNET}/provisioning/datasources
	@${BUILD_HARNESS_EXTENSIONS_PATH}/modules/grafana/scripts/patch_datasources.sh "${TMP_MONITORING_CLUSTER_JSONNET}" > ${TMP_GRAFANA_DATASOURCES}
	@. ${BUILD_HARNESS_EXTENSIONS_PATH}/modules/grafana/scripts/datasource_credentials.sh && \
		MINTEL_BASE_URL='$(MINTEL_BASE_URL)' \
		docker run \
			--rm -d -p 3000:3000 --user $(UID):$(UID) \
			-v ${TMP_GRAFANA_DATASOURCES}:/etc/grafana/provisioning/datasources/automatic.yml \
			-v ${HOME}/.aws:/usr/share/grafana/.aws \
			--env-file ${BUILD_HARNESS_EXTENSIONS_PATH}/modules/grafana/env.list \
			-e GF_AUTH_ANONYMOUS_ORG_ROLE=Admin \
			-e GF_AUTH_ANONYMOUS_ENABLED=true \
			-e GF_INSTALL_PLUGINS=${GRAFANA_PLUGINS} \
			-e GF_FEATURE_TOGGLES_ENABLE=traceqlEditor \
			-e GF_DATAPROXY_TIMEOUT=300 \
			-e GF_DATAPROXY_KEEP_ALIVE_SECONDS=300 \
			-e AWS_PROFILE \
			-e AWS_SDK_LOAD_CONFIG=true \
			-e AWS_EC2_METADATA_DISABLED=1 \
			--name ${GRAFANA_LOCAL_DOCKER_NAME} \
			$(GRAFANA_IMAGE)

grafana/setup-local-grafana-oss:
	@docker pull $(GRAFANA_IMAGE)
	@docker run --rm -d -p 3000:3000 --name ${GRAFANA_LOCAL_DOCKER_NAME} $(GRAFANA_IMAGE)

grafana/wait-for-grafana:
ifeq (${CREATE_GRAFANA_INSTANCE}, true)
# Give the grafana instance time to start up before changing the admin password in order to avoid errors
	@echo "Starting grafana on localhost:3000 ..."
	# Need to sleep for a bit and wait for plugins to be installed...
	@while ! curl -s localhost:3000/api/health > /dev/null; do sleep 0.25; done
	@docker exec -it ${GRAFANA_LOCAL_DOCKER_NAME} grafana cli --homepath "/usr/share/grafana" admin reset-admin-password ${GRAFANA_ADMIN_PASSWORD}
endif

## Run grafana/mcp-grafana as a sidecar so LLM agents can drive the local Grafana instance.
grafana/setup-grafana-mcp: grafana/wait-for-grafana
ifeq (${CREATE_GRAFANA_MCP}, true)
	@docker pull $(MCP_GRAFANA_IMAGE)
	@docker run --rm -d \
		--network="host" \
		--name ${GRAFANA_MCP_DOCKER_NAME} \
		-e GRAFANA_URL=http://localhost:3000 \
		-e GRAFANA_USERNAME=admin \
		-e GRAFANA_PASSWORD=${GRAFANA_ADMIN_PASSWORD} \
		$(MCP_GRAFANA_IMAGE) -t streamable-http --address 0.0.0.0:${MCP_GRAFANA_PORT} \
			--disable-incident \
			--disable-influxdb \
			--disable-alerting \
			--disable-oncall \
			--disable-asserts \
			--disable-sift \
			--disable-pyroscope \
			--disable-clickhouse \
			--disable-runpanelquery \
			--disable-graphite
	@echo ""
	@echo "mcp-grafana is running on http://localhost:${MCP_GRAFANA_PORT}/mcp"
	@echo "Add it to Claude Code with:"
	@echo "  claude mcp add --transport http grafana http://localhost:${MCP_GRAFANA_PORT}/mcp"
	@echo ""
endif

grafana/setup-grafana-syncer: grafana/wait-for-grafana
	@docker pull mintel/grafana-local-sync:latest
	@docker run --rm -it --user $(UID):$(UID) --mount type=bind,source=$$PWD/${LOCAL_DASHBOARD_DIRECTORY},target=${CONTAINER_DASHBOARD_DIRECTORY}/LocalDev --network="host" --name ${GRAFANA_SYNC_DOCKER_NAME} mintel/grafana-local-sync:latest -user admin -pass ${GRAFANA_ADMIN_PASSWORD} -dir ${CONTAINER_DASHBOARD_DIRECTORY}
	@$(MAKE) grafana/cleanup
