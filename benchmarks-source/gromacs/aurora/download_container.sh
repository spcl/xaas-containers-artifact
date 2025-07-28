#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${HOME}/xaas-containers-artifact}
ARTIFACT_REPOSITORY=${ARTIFACT_REPOSITORY:-"spcleth/xaas-artifact"}
CONTAINER_PATH="${ARTIFACT_LOCATION}/data/gromacs/images/"

mkdir -p ${CONTAINER_PATH}

echo "Download specialized container"
# FIXME: write actual build 
# destination ${CONTAINER_PATH}/gromacs-mpi-ipc.sing

echo "Download XaaS Source container"
# FIXME: write actual build
# destination ${CONTAINER_PATH}/gromacs-xaas-source.sing

# FIXME: is this the correct one?
echo "Download XaaS Source + GPU container"
apptainer build ${CONTAINER_PATH}/gromacs-xaas-source-gpu.sing docker://spcleth/xaas-artifact:source-gromacs-aurora-no-mpi-gpu-support
