#!/bin/bash

APP_NAME=$1

NAMESPACE=${NAMESPACE:-""}
OWNER=${OWNER:-""}
IMAGE_REPOSITORY=${IMAGE_REPOSITORY:-""}
IMAGE_TAG=${IMAGE_TAG:-""}
PORT=${PORT:-""}

echo ""

if [ -z "${APP_NAME}" ]; then
  echo "Must specify an application name"
  exit 1
fi
if [ -d "lib/${APP_NAME}" ] || [ -d "environments/${APP_NAME}" ]; then
  echo "Application already exists by the name '${APP_NAME}'"
  exit 1
fi

if [ "${NAMESPACE}" = "" ]; then
  environments=$(tk env list --json)
  if [ "$environments" != null ]; then
    mapfile -t namespaces <<< "$(echo "$environments" | jq -r '.[].spec.namespace' | sort | uniq | grep -v default)"
  fi
  namespaces+=("(new)")
  PS3="Choose a namespace: "
  select ns in "${namespaces[@]}"; do
    case $ns in 
      "(new)")
        echo -n "Enter new namespace: "
        read -r ns
        break
        ;;
      *)
        break
        ;;
    esac
  done
  NAMESPACE=$ns
fi

if [ "${OWNER}" = "" ]; then
  echo "Owner:"
  read -r owner
  OWNER=$owner
fi
OWNER=$(echo "$OWNER" | iconv -t ascii//TRANSLIT | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr '[:upper:]' '[:lower:]')

if [ "${IMAGE_REPOSITORY}" = "" ]; then
  echo "Repository of image to deploy, eg: mintel/portal/portal (note: if not a mintel gitlab repo then you will need to update the 'registry' value manually"
  read -r repository
  IMAGE_REPOSITORY=$repository
fi

if [ "${IMAGE_TAG}" = "" ]; then
  echo "Tag of the image to deploy:"
  read -r tag
  IMAGE_TAG=$tag
fi

if [ "${PORT}" = "" ]; then
  echo "Main port that the container image exposes, eg: 8080:"
  read -r port
  PORT=$port
fi

# shellcheck disable=SC2086
mkdir -p lib/${APP_NAME}
# shellcheck disable=SC2086
mkdir -p environments/${APP_NAME}/{local,aws.dev,aws.qa,aws.prod}


echo "local m = import 'gitlab.com/mintel/satoshi/kubernetes/jsonnet/sre/libs-jsonnet/utils/main.libsonnet';
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
    m.wrappers.helmApp('../../charts/standard-application-stack', $.appValues, $._config),
}" > "lib/${APP_NAME}/base.libsonnet"

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
    labels: {
      app: '${APP_NAME}',
      env: '${ENV}',
    },
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
}" > "environments/${APP_NAME}/${ENV}/main.jsonnet"
done

echo
echo "Make sure you review and edit the generated ./lib/${APP_NAME}/base.libsonnet file"
