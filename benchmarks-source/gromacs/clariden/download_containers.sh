#!/bin/bash
#SBATCH --job-name=gromacs_download
#SBATCH --time=00:10:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=72
#SBATCH --account=a-g200
#SBATCH --output=download_containers.out
#SBATCH --error=download_containers.err
#SBATCH --uenv=prgenv-gnu/24.11:v1
#SBATCH --view=modules

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}
DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

cd ${ARTIFACT_LOCATION}/benchmarks-source/gromacs/clariden/build-scripts/testcase2

CONTAINER_IMAGE=gromacs_clariden.sqsh
IMAGE_NAME=gromacs-source-deploy-clariden

rm ${CONTAINER_IMAGE}
podman pull docker.io/${DOCKER_REPOSITORY}:${IMAGE_NAME}
enroot import -x mount -o ${CONTAINER_IMAGE} podman://xaas-artifact:${IMAGE_NAME}
