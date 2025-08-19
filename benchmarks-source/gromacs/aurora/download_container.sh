#!/bin/bash
#PBS -A workflow_scaling
#PBS -N gromacs_container_pull
#PBS -l walltime=00:60:00
#PBS -l filesystems=flare
#PBS -q debug

module load apptainer

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${HOME}/xaas-containers-artifact}
DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}
CONTAINER_PATH="${ARTIFACT_LOCATION}/data/gromacs/images/"

mkdir -p ${CONTAINER_PATH}

echo "Download specialized container"
apptainer build ${CONTAINER_PATH}/gromacs-mpi-ipc.sing docker://${DOCKER_REPOSITORY}:gromacs-aurora-specialized

echo "Download XaaS Source container"
apptainer build ${CONTAINER_PATH}/gromacs-xaas-source.sing docker://${DOCKER_REPOSITORY}:gromacs-source-deploy-aurora

echo "Download XaaS Source + GPU container"
apptainer build ${CONTAINER_PATH}/gromacs-xaas-source-gpu.sing docker://${DOCKER_REPOSITORY}:gromacs-source-deploy-aurora-gpu-fix
