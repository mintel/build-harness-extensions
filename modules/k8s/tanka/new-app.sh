#!/bin/bash

APP_NAME=$1

NAMESPACE=${NAMESPACE:-""}
OWNER=${OWNER:-""}
IMAGE_REPOSITORY=${IMAGE_REPOSITORY:-""}
IMAGE_TAG=${IMAGE_TAG:-""}
PORT=${PORT:-""}

echo ""

if [ -z ${APP_NAME} ]; then
  echo "Must specify an application name"
  exit 1
fi
if [ -d "lib/${APP_NAME}" ] || [ -d "environments/${APP_NAME}" ]; then
  echo "Application already exists by the name '${APP_NAME}'"
  exit 1
fi

if [ "${NAMESPACE}" = "" ]; then
  namespaces=$(tk env list --json | jq -r '.[].spec.namespace' | sort | uniq)
  if [ ${#namespaces[@]} == 1 ]; then
    NAMESPACE="${namespaces[0]}"
  else
    echo "Namespace:"
    read ns
    NAMESPACE=$ns
  fi
fi

if [ "${OWNER}" = "" ]; then
  echo "Owner:"
  read owner
  OWNER=$owner
fi
OWNER=`echo "$OWNER" | iconv -t ascii//TRANSLIT | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z`

if [ "${IMAGE_REPOSITORY}" = "" ]; then
  echo "Repository of image to deploy, eg: mintel/portal/portal (note: if not a mintel gitlab repo then you will need to update the 'registry' value manually"
  read repository
  IMAGE_REPOSITORY=$repository
fi

if [ "${IMAGE_TAG}" = "" ]; then
  echo "Tag of the image to deploy:"
  read tag
  IMAGE_TAG=$tag
fi

if [ "${PORT}" = "" ]; then
  echo "Main port that the container image exposes, eg: 8080:"
  read port
  PORT=$port
fi

mkdir -p lib/${APP_NAME}
mkdir -p environments/${APP_NAME}/{local,aws.dev,aws.qa,aws.prod}


echo "(import 'gitlab.com/mintel/satoshi/kubernetes/jsonnet/sre/libs-jsonnet/mintel-util/main.libsonnet')
{
  _config+:: {
    namespace: '${NAMESPACE}',
    partOf: '${APP_NAME}',
    owner: '${OWNER}',
    name: '${APP_NAME}',
  },

  appValues:: {
    global: $._config,
    image: {
      repository: '${IMAGE_REPOSITORY}',
      tag: '${IMAGE_TAG}',
    },
    port: ${PORT},
    replicas: 2,
    env: {
    },
    resources: {
      requests: {
        cpu: '100m',
        memory: '32Mi',
      },
      limits: {
        cpu: '200m',
        memory: '64Mi',
      },
    },
  },

  app:
    $.util.mintel.helm.wrapper('../../charts/standard-application-stack', $.appValues),
}" > lib/${APP_NAME}/main.libsonnet

environments=("local" "aws.dev" "aws.qa" "aws.prod")
for ENV in "${environments[@]}"
do
  API_SERVER=""
  if [ "$ENV" == "local" ]; then
    API_SERVER="\n    apiServer: 'https://0.0.0.0:6443',"
  fi

  echo -e "{
  apiVersion: 'tanka.dev/v1alpha1',
  kind: 'Environment',
  metadata: {
    name: 'environments/${APP_NAME}/${ENV}',
  },
  spec: {
    namespace: $.data._config.namespace,${API_SERVER}
  },
  data:
    (import 'gitlab.com/mintel/satoshi/kubernetes/jsonnet/sre/cluster-env-jsonnet/${ENV}.libsonnet') +
    (import '${APP_NAME}/base.libsonnet') +
    {
      appValues+:: {
      },
    },
}" > environments/${APP_NAME}/${ENV}/main.jsonnet
done

echo
echo "Make sure you review and edit the generated ./lib/${APP_NAME}/base.libsonnet file"
