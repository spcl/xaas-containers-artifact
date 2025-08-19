#!/bin/bash

DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

echo "Building container ${DOCKER_REPOSITORY}:gromacs-aurora-specialized"

docker build -t ${DOCKER_REPOSITORY}:gromacs-aurora-specialized -f ./build_scripts/container-specialized/Dockerfile -
docker push ${DOCKER_REPOSITORY}:gromacs-aurora-specialized
