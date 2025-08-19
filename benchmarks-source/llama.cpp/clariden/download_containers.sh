#!/bin/bash
#SBATCH --job-name=llama_build
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

cd ${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/clariden/build-scripts/testcase3

CONTAINER_IMAGE=llamacpp_clariden.sqsh
IMAGE_NAME=llama.cpp-source-deploy-clariden

rm ${CONTAINER_IMAGE}
podman pull docker.io/spcleth/xaas-artifact:${IMAGE_NAME}
enroot import -x mount -o ${CONTAINER_IMAGE} podman://xaas-artifact:${IMAGE_NAME}

cd ${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/clariden/build-scripts/testcase2
CONTAINER_IMAGE=llamacpp_clariden.sqsh
IMAGE_NAME=llamacpp-specialized-clariden

rm ${CONTAINER_IMAGE}
podman pull docker.io/spcleth/xaas-artifact:${IMAGE_NAME}
enroot import -x mount -o ${CONTAINER_IMAGE} podman://xaas-artifact:${IMAGE_NAME}
