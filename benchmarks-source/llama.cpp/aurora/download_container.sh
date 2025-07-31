#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${HOME}/xaas-containers-artifact}
ARTIFACT_REPOSITORY=${ARTIFACT_REPOSITORY:-"spcleth/xaas-artifact"}
CONTAINER_PATH="${ARTIFACT_LOCATION}/data/gromacs/images/"

mkdir -p ${CONTAINER_PATH}

# FIXME: is this the correct one?
echo "Download XaaS Source "
# FIXME: write actual download
# destination ${CONTAINER_PATH}/source-llamacpp-aurora.sing
