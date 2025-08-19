#!/bin/bash

DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

SPECIALIZATION=$1
BUILD_FLAG=${2:-"1"}

if [[ "$BUILD_FLAG" == "0" ]]; then
  BUILD_FLAG="--no-build"
else
  BUILD_FLAG=""
fi

echo "Creating images in Docker repository: ${DOCKER_REPOSITORY}"

# replace docker registry in the name of source image
yq ".source_container |= sub(\"spcleth/xaas-artifact\", \"${DOCKER_REPOSITORY}\")" ${SPECIALIZATION} >${SPECIALIZATION}_
yq ".docker_repository = \"${DOCKER_REPOSITORY}\"" ${SPECIALIZATION}_ >${SPECIALIZATION}__

echo "Using specialization ${SPECIALIZATION}"

xaas source deploy ${SPECIALIZATION}__ ${BUILD_FLAG}
