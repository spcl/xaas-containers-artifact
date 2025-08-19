#!/bin/bash

DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

echo "Creating images in Docker repository: ${DOCKER_REPOSITORY}"

echo "Pushing gromacs source container for x86_64"
docker push ${DOCKER_REPOSITORY}/gromacs-source-x86_64
echo "Pushing gromacs source container for arm64"
docker push ${DOCKER_REPOSITORY}/gromacs-source-arm64
