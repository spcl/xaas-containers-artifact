#!/bin/bash
#PBS -A workflow_scaling
#PBS -N llama_xaas_pull
#PBS -l walltime=00:60:00
#PBS -l filesystems=flare
#PBS -q debug

module load apptainer

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${HOME}/xaas-containers-artifact}
ARTIFACT_REPOSITORY=${ARTIFACT_REPOSITORY:-"spcleth/xaas-artifact"}
CONTAINER_PATH="${ARTIFACT_LOCATION}/data/gromacs/images/"

mkdir -p ${CONTAINER_PATH}

echo "Download XaaS Source "
apptainer build ${CONTAINER_PATH}/source-llamacpp-aurora.sing docker://${ARTIFACT_REPOSITORY}:source-llamacpp-aurora
