#!/bin/bash

DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

dockerfile="gromacs-builds/Dockerfile.deployment-aurora"
flags="-DGMX_GPU_NB_NUM_CLUSTER_PER_CELL_X=1 -DGMX_GPU_NB_CLUSTER_SIZE=8"

[[ ! -f "$dockerfile" ]] && {
  echo "Error: basic $dockerfile not found"
  exit 1
}

cp "$dockerfile" "${dockerfile}-gpu"

sed -i "/cmake ../ s/\\\\$/ $flags \\\\/" "${dockerfile}-gpu"

echo "Added GPU compatibility flags: $flags to the new file ${dockerfile}-gpu"

IMAGE_NAME="gromacs-source-deploy-aurora-gpu-fix"
echo "Building new image ${DOCKER_REPOSITORY}:${IMAGE_NAME} from ${dockerfile}-gpu"
docker build -t ${DOCKER_REPOSITORY}:${IMAGE_NAME} -f ${dockerfile}-gpu .
